
import json, datetime, os
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
db_host = os.environ.get("DBHOST")
db_user = os.environ.get("DBUSER")
db_pass = os.environ.get("DBPASS")
db_name = os.environ.get("DBNAME")
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://' + str(db_user) + ':' + str(db_pass) + '@' + str(db_host) + '/' + str(db_name)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False # deprecated
db = SQLAlchemy(app)

class User(db.Model):
    __tablename__ = 'users'

    name = db.Column(db.String(80), unique=True, primary_key=True)
    birthday = db.Column('birthday_epoch', db.Integer, unique=False)


def birthday_calc(birthday_epoch, name):
    # get year day for the birthday and today
    birthday_year_day = datetime.date.fromtimestamp(birthday_epoch).strftime("%j")
    today_year_day = datetime.date.today().strftime("%j")

    # get the difference between birthday and today in days
    diff = int(birthday_year_day) - int(today_year_day)
    if diff < 0:
        diff += 365

    if diff == 0:
        result_str = "Hello, " + str(name) + "! Happy Birthday!"
    else:
        result_str = "Hello, " + str(name) + "! Your birthday is in " + str(diff) + " days"
    
    return result_str

# healthcheck to put in service
@app.route("/__health", methods=["GET"])
def healthcheck():
    try:
        db.session.query("1").from_statement("SELECT 1").all()
        resp_message = "UP\n"
        resp_code = 200
    except:
        resp_message = "DOWN\n"
        resp_code = 500

    return (resp_message, resp_code,)


# GET endpoint to show the greeting message
@app.route("/hello/<name>", methods=["GET"])
def get_user(name):
    try:
        user = User.query.get(name)
        resp_message = '{ "message": "'+ str(birthday_calc(user.birthday, user.name)) + '" }\n'
        status_code = 200
    except:
        resp_message = "Something went wrong ...\n"
        status_code = 500

    return (resp_message, status_code, )

# PUT endpoint to update user birthday
@app.route("/hello/<name>", methods=["PUT"])
def user_update(name):
    try:
        user = User.query.get(name)
        birthday = datetime.datetime.strptime(str(request.json["dateOfBirth"]), "%Y-%m-%d").strftime('%s')

        if user:
            user.birthday = birthday
            user.name = name
        else: 
            new_user = User(name = name, birthday = birthday)
            db.session.add(new_user)

        resp_message = "No content\n"
        status_code = 201
        db.session.commit()

    except:
        resp_message = "Something went wrong ...\n"
        status_code = 500
        
    return (resp_message, status_code,)


if __name__ == '__main__':
    app.run(host='0.0.0.0')
