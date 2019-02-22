# Author: Dirk Duclos
#
# Purpose: Senior Year Project - built using Flask, a web
#		   API framework in Python. Also use SQLALchemy for ORM mapping
#		   to a database. This code is built around being a RESTful Web API
#		   between Flutter and PostgreSQL database. This program is essentially
#          the Web API for mobile application BrainTrain
#
# Modified: 1-19-19

# --------- python imports -------- #
import psycopg2
import json
from cryptography.fernet import Fernet
from flask import *

# ------ flask imports ------ #
from flask import Flask, jsonify


# --------- sqlalchemy imports --------- #
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine
# import for foreign keys
from sqlalchemy.orm import relationship
# imports for bridge tables
from sqlalchemy.ext.declarative import declarative_base
Base = declarative_base()


key = b'WivDxfIlt3NV96c7Iu-kVM45XDmurew6AY_b_9p1_zk='
cipher_suite = Fernet(key)
# get already encrypted pass
with open('C:\\inetpub\\wwwroot\\postgres_BT_bytes.bin','rb') as file_object:
	for line in file_object:
		ep =  line
ut = (cipher_suite.decrypt(ep))
# bytes -> string
ptep = bytes(ut).decode("utf-8")

#-------------------------------------------------#
#                 DB CONNECTION                   #
#-------------------------------------------------#

dbconn = 'postgresql+psycopg2://postgres:' + ptep + '@localhost:5432/BrainTrain_App_WS'
app = Flask(__name__)
#connect to DB
app.config['SQLALCHEMY_DATABASE_URI'] = dbconn
#create db object from SQLAlchemy into Flask
db = SQLAlchemy(app)

# make engine for DB instance
engi = create_engine(dbconn)

# ************* BRIDGE TABLES ************** #
# These tables are for many to many          #
# relationships in the DB (database)         #
# ****************************************** #

#parent_player bridge table
parent_player_bridge = db.Table('parent_player',
db.Model.metadata,
db.Column('Parent_id',db.Integer,db.ForeignKey('BT_App_WS.parent.parent_id')),
db.Column('Player_id',db.Integer,db.ForeignKey('BT_App_WS.player.player_id'))
)

#teacher_player bridge table
teacher_player_bridge = db.Table('teacher_player',
db.Model.metadata,
db.Column('Teacher_id',db.Integer,db.ForeignKey('BT_App_WS.teacher.teacher_id')),
db.Column('Player_id',db.Integer,db.ForeignKey('BT_App_WS.player.player_id'))
)

# ********** END OF BRIDGE TABLES ********* #


#-------------------------------------------------#
#                DB OBJECT TABLES                 #
# This will allow mapping of Python objects to    #
# objects in the actual database, this is ORM  	  #
# aspect of SQLAlchemy                            #
#-------------------------------------------------#

# parent table/definitions
class Parent(db.Model):
	__tablename__ = 'parent'
	__table_args__ = {'schema':'BT_App_WS'}
	id = db.Column('parent_id',db.Integer,primary_key=True)
	uname = db.Column('uname', db.String(50))
	email = db.Column('email',db.String(50))
	password = db.Column('password',db.String(50))
	# many to many relationships
	players = relationship("Player",secondary=parent_player_bridge,back_populates="parent")

	#initialize variables for queries to/from DB
	#this is what is known as a class constructor
	def __init__(self,uname,parent_id,email,password):
		self.id = id
		self.uname = ''.join(uname.split())
		self.email = email
		self.password = password

# ********************************************* #
# All app.routes will be the development of     #
# the REST API for the project, with methods    #
# such as GET, POST, DELETE, etc.               #
# ********************************************* #

# ALL parents in DB,JSON format
@app.route('/bt_api/parents', methods=['GET'])
#if(request.method == 'GET')
def list_all_parents():
	# isolate a db connection
	connection = engi.connect().connection

	#setup cursor on connection for query to object
	cursor = connection.cursor()

	# display parent info
	# Note: Select all relevant tables in table, avoid using * (i.e., SELECT *)
	query = "set search_path = \"BT_App_WS\"; SELECT parent_id,trim(uname),trim(email),trim(password) from parent;"

	#execute query
	cursor.execute(query)

	#fetch all results from cursor object holding query results
	result = cursor.fetchall()

	#turn list from result into JSON format, using flask's jsonify
	#to make more readable display
	parentList = []
	for parent in result:
		parentDict = {
		"parent_id": parent[0],
		"username": parent[1],
		"email": parent[2],
		"password": parent[3]
		}
		parentList.append(parentDict)
	return jsonify(parentList)


#player table
class Player(db.Model):
	__tablename__ = 'player'
	__table_args__ = {'schema':'BT_App_WS'}
	id = db.Column('player_id',db.Integer,primary_key=True)
	uname = db.Column('uname', db.String(50))
	age = db.Column('age',db.Integer)
	# one to many relationships
	assoc = relationship("PlayerAssociation")
	lang = relationship("PlayerLanguage")
	math = relationship("PlayerMath")
	mem = relationship("PlayerMemorization")
	motor_skills = relationship("PlayerMotorSkills")
	# many to many relationships
	parents = relationship("Parent",secondary=parent_player_bridge,back_populates="player")
	teachers = relationship("Teacher",secondary=teacher_player_bridge,back_populates="player")

	def __init__(self,uname,player_id,age):
		self.id = id
		self.uname = ''.join(uname.split())
		self.age = age

@app.route('/bt_api/players', methods=['GET'])
def list_all_players():

	connection = engi.connect().connection
	cursor = connection.cursor()
	query = "set search_path = \"BT_App_WS\"; SELECT player_id,trim(uname),age from player;"
	cursor.execute(query)
	result = cursor.fetchall()

	playerList = []
	for player in result:
		playerDict = {
		"player_id": player[0],
		"username": player[1],
		"age": player[2]
		}
		playerList.append(playerDict)
	return jsonify(playerList)

#teacher table
class Teacher(db.Model):
	__tablename__ = 'teacher'
	__table_args__ = {'schema':'BT_App_WS'}
	id = db.Column('teacher_id',db.Integer,primary_key=True)
	classNumber = db.Column('class_num',db.Integer)
	ageGroup = db.Column('age_group',db.String(3))
	uname = db.Column('uname', db.String(50))
	email = db.Column('email',db.String(50))
	password = db.Column('password',db.String(50))
	# many to many relationships
	students = relationship("Player",secondary=teacher_player_bridge,back_populates="teacher")

	def __init__(self,uname,teacher_id,class_num,age_group,email,password):
		self.id = id
		self.classNumber = classNumber
		self.ageGroup = ''.join(ageGroup.split())
		self.uname = ''.join(uname.split())
		self.email = email
		self.password = password

@app.route('/bt_api/teachers', methods=['GET'])
def list_all_teachers():

	connection = engi.connect().connection
	cursor = connection.cursor()
	query = "set search_path = \"BT_App_WS\"; SELECT teacher_id,class_num,trim(age_group),trim(uname),trim(email),trim(password) from teacher;"
	cursor.execute(query)
	result = cursor.fetchall()

	teacherList = []
	for teacher in result:
		teacherDict = {
		"teacher_id": teacher[0],
		"class_num": teacher[1],
		"age_group": teacher[2],
		"username": teacher[3],
		"email": teacher[4],
		"password": teacher[5]
		}
		teacherList.append(teacherDict)
	return jsonify(teacherList)


#player association table (many to many relation)
class PlayerAssociation(db.Model):
	__tablename__ = 'player_association'
	__table_args__ = {'schema':'BT_App_WS'}
	id = db.Column('player_association_id',db.Integer,primary_key=True)
	stars = db.Column('association_stars',db.Integer)
	game_name = db.Column('association_game_name',db.String(50))
	startTime = db.Column('start_time',db.TIMESTAMP)
	endTime = db.Column('end_time',db.TIMESTAMP)
	#Foreign Key Column
	playerid = db.Column('Player_id',db.Integer,db.ForeignKey('BT_App_WS.player.player_id'))

	def __init__(self,association_stars,player_association_id,association_game_name,start_time,end_time,Player_id):
		self.id = id
		self.stars = stars
		self.game_name = game_name
		self.startTime = startTime
		self.endTime = endTime
		self.playerid = playerid

@app.route('/bt_api/player_associations', methods=['GET'])
def list_all_player_associations():

	connection = engi.connect().connection
	cursor = connection.cursor()
	query = "set search_path = \"BT_App_WS\"; SELECT player_association_id,association_stars,trim(association_game_name),start_time,end_time,\"Player_id\" from player_association;"
	cursor.execute(query)
	result = cursor.fetchall()

	playerAssociationsList = []
	for playerAssociations in result:
		playerAssociationsDict = {
		"player_association_id" : playerAssociations[0],
		"stars" : playerAssociations[1],
		"game_name" : playerAssociations[2],
		"start_time" : playerAssociations[3],
		"end_time" : playerAssociations[4],
		"Player_id": playerAssociations[5]
		}
		playerAssociationsList.append(playerAssociationsDict)
	return jsonify(playerAssociationsList)

#player language table (one to many relation)
class PlayerLanguage(db.Model):
	__tablename__ = 'player_language'
	__table_args__ = {'schema':'BT_App_WS'}
	id = db.Column('player_language_id',db.Integer,primary_key=True)
	stars = db.Column('language_stars',db.Integer)
	game_name = db.Column('language_game_name',db.String(50))
	startTime = db.Column('start_time',db.TIMESTAMP)
	endTime = db.Column('end_time',db.TIMESTAMP)
	#Foreign Key Column
	playerid = db.Column('Player_id',db.Integer,db.ForeignKey('BT_App_WS.player.player_id'))

	def __init__(self,language_stars,player_language_id,language_game_name,start_time,end_time,Player_id):
		self.id = id
		self.stars = stars
		self.game_name = game_name
		self.startTime = startTime
		self.endTime = endTime
		self.playerid = playerid

@app.route('/bt_api/player_languages', methods=['GET'])
def list_all_player_languages():

	connection = engi.connect().connection
	cursor = connection.cursor()
	query = "set search_path = \"BT_App_WS\"; SELECT player_language_id,language_stars,trim(language_game_name),start_time,end_time,\"Player_id\" from player_language;"
	cursor.execute(query)
	result = cursor.fetchall()

	playerLanguagesList = []
	for playerLanguages in result:
		playerLanguagesDict = {
		"player_association_id" : playerLanguages[0],
		"stars" : playerLanguages[1],
		"game_name" : playerLanguages[2],
		"start_time" : playerLanguages[3],
		"end_time" : playerLanguages[4],
		"Player_id" : playerLanguages[5]
		}
		playerLanguagesList.append(playerLanguagesDict)
	return jsonify(playerLanguagesList)

#player math table (one to many relation)
class PlayerMath(db.Model):
	__tablename__ = 'player_math'
	__table_args__ = {'schema':'BT_App_WS'}
	id = db.Column('player_math_id',db.Integer,primary_key=True)
	stars = db.Column('math_stars',db.Integer)
	game_name = db.Column('math_game_name',db.String(50))
	startTime = db.Column('start_time',db.TIMESTAMP)
	endTime = db.Column('end_time',db.TIMESTAMP)
	#Foreign Key Column
	playerid = db.Column('Player_id',db.Integer,db.ForeignKey('BT_App_WS.player.player_id'))

	def __init__(self,math_stars,player_math_id,math_game_name,start_time,end_time,Player_id):
		self.id = id
		self.stars = stars
		self.game_name = game_name
		self.startTime = startTime
		self.endTime = endTime
		self.playerid = playerid

@app.route('/bt_api/player_maths', methods=['GET'])
def list_all_player_maths():

	connection = engi.connect().connection
	cursor = connection.cursor()
	query = "set search_path = \"BT_App_WS\"; SELECT player_math_id,math_stars,trim(math_game_name),start_time,end_time,\"Player_id\" from player_math;"
	cursor.execute(query)
	result = cursor.fetchall()

	playerMathsList = []
	for playerMaths in result:
		playerMathsDict = {
		"player_math_id" : playerMaths[0],
		"stars" : playerMaths[1],
		"game_name" : playerMaths[2],
		"start_time" : playerMaths[3],
		"end_time" : playerMaths[4],
		"Player_id" : playerMaths[5]
		}
		playerMathsList.append(playerMathsDict)
	return jsonify(playerMathsList)

#player memorization table (one to many relation)
class PlayerMemorization(db.Model):
	__tablename__ = 'player_memorization'
	__table_args__ = {'schema':'BT_App_WS'}
	id = db.Column('player_memorization_id',db.Integer,primary_key=True)
	stars = db.Column('memorization_stars',db.Integer)
	game_name = db.Column('memorization_game_name',db.String(50))
	startTime = db.Column('start_time',db.TIMESTAMP)
	endTime = db.Column('end_time',db.TIMESTAMP)
	#Foreign Key Column
	playerid = db.Column('Player_id',db.Integer,db.ForeignKey('BT_App_WS.player.player_id'))

	def __init__(self,memorization_stars,player_memorization_id,memorization_game_name,start_time,end_time,Player_id):
		self.id = id
		self.stars = stars
		self.game_name = game_name
		self.startTime = startTime
		self.endTime = endTime
		self.playerid = playerid

@app.route('/bt_api/player_memorizations', methods=['GET'])
def list_all_player_memorizations():

	connection = engi.connect().connection
	cursor = connection.cursor()
	query = "set search_path = \"BT_App_WS\"; SELECT player_memorization_id,memorization_stars,trim(memorization_game_name),start_time,end_time,\"Player_id\" from player_memorization;"
	cursor.execute(query)
	result = cursor.fetchall()

	playerMemorizationsList = []
	for playerMemorizations in result:
		playerMemorizationsDict = {
		"player_math_id" : playerMemorizations[0],
		"stars" : playerMemorizations[1],
		"game_name" : playerMemorizations[2],
		"start_time" : playerMemorizations[3],
		"end_time" : playerMemorizations[4],
		"Player_id" : playerMemorizations[5]
		}
		playerMemorizationsList.append(playerMemorizationsDict)
	return jsonify(playerMemorizationsList)

#player motor skills table (one to many relation)
class PlayerMotorSkills(db.Model):
	__tablename__ = 'player_motor_skills'
	__table_args__ = {'schema':'BT_App_WS'}
	id = db.Column('player_motor_skills_id',db.Integer,primary_key=True)
	stars = db.Column('motor_skills_stars',db.Integer)
	game_name = db.Column('motor_skills_game_name',db.String(50))
	startTime = db.Column('start_time',db.TIMESTAMP)
	endTime = db.Column('end_time',db.TIMESTAMP)
	#Foreign Key Column
	playerid = db.Column('Player_id',db.Integer,db.ForeignKey('BT_App_WS.player.player_id'))

	def __init__(self,motor_skills_stars,player_motor_skills_id,motor_skills_game_name,start_time,end_time,Player_id):
		self.id = id
		self.stars = stars
		self.game_name = game_name
		self.startTime = startTime
		self.endTime = endTime
		self.playerid = playerid

@app.route('/bt_api/player_motor_skillss', methods=['GET'])
def list_all_player_motor_skillss():

	connection = engi.connect().connection
	cursor = connection.cursor()
	query = "set search_path = \"BT_App_WS\"; SELECT player_motor_skills_id,motor_skills_stars,trim(motor_skills_game_name),start_time,end_time,\"Player_id\" from player_motor_skills;"
	cursor.execute(query)
	result = cursor.fetchall()

	playerMotorSkillssList = []
	for playerMotorSkillss in result:
		playerMotorSkillssDict = {
		"player_motor_skills_id" : playerMotorSkillss[0],
		"stars" : playerMotorSkillss[1],
		"game_name" : playerMotorSkillss[2],
		"start_time" : playerMotorSkillss[3],
		"end_time" : playerMotorSkillss[4],
		"Player_id" : playerMotorSkillss[5]
		}
		playerMotorSkillssList.append(playerMotorSkillssDict)
	return jsonify(playerMotorSkillssList)

# ********** END OF DB OBJECT TABLES ********* #
if __name__  == '__main__':
	app.run()
