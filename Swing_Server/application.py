from flask import Flask, request
from sparkpost import SparkPost
from random import randint
from datetime import datetime
from rapidconnect import RapidConnect
import requests
import boto3
import json
from flask_cors import CORS, cross_origin

spark_api_key = '05679ea3c719ddb28c8a3d34091e9b4714c3927d'
sp = SparkPost(spark_api_key)
s3 = boto3.resource('s3')

def send_email(unique_id, website_url, email):

    response = sp.transmissions.send(
            recipients=[email],
            html='<h3>Congratulations!</h3> <p>Your website is now live! Check it out at ' + website_url,
            from_email='email@email.100interns.com',
            subject='Your website is now live!'
        )
    print(response)

def create_buckets(bucketid, email):
    bucket = s3.create_bucket(Bucket=bucketid)
    bucket.wait_until_exists()
    print(email)
    s3.Object(bucketid, 'index.html').put(
        ACL='public-read',
        ContentType='text/html',
        Body=open('index.html', 'rb')
    )
    bucket_website = bucket.Website()
    bucket_website.put(WebsiteConfiguration={'IndexDocument': {'Suffix': 'index.html'}})
    send_email(bucketid, 'http://' + bucketid + '.s3-website-us-east-1.amazonaws.com', email)
    return 'Done'

application = Flask(__name__)
CORS(application)

def get_gif():
    rapid = RapidConnect('revamp', '0b94c5ad-c5c0-4313-8435-6f8170dc8473');

    result = rapid.call('Giphy', 'getRandomGif', { 
        'rating': 'y',
        'apiKey': 'dc6zaTOxFJmzC',
        'tag': 'happy'

    });
    # print(result['data']['image_url'])
    return result['data']['image_url']

def get_gif_sad():
    rapid = RapidConnect('revamp', '0b94c5ad-c5c0-4313-8435-6f8170dc8473');

    result = rapid.call('Giphy', 'getRandomGif', { 
        'rating': 'y',
        'apiKey': 'dc6zaTOxFJmzC',
        'tag': 'sad'

    });
    # print(result['data']['image_url'])
    return result['data']['image_url']


@application.route('/', methods=['GET'])
def load_temp():
    return 'Hello World'

@application.route('/<num>', methods=['GET'])
def update_number(num):
    r = requests.get('https://swing-c93c1.firebaseio.com/data.json')
    data = r.json()
    myData = {}
    myData['current'] = data['current']
    myData['score'] = int(num)
    r = requests.put('https://swing-c93c1.firebaseio.com/data.json', data=json.dumps(myData))
    return 'Done'

@application.route('/joined/<email>', methods=['GET'])
def send_join_email(email):
    response = sp.transmissions.send(
        recipients=[email],
        html='<h3>Swing!</h3><p>Hey there! Thank you for stopping by, we hope you enjoyed your experience with Swing and we hope to see you again. Click this link to see the leader board: http://bit.ly/2eUjp4g </p>' + '<p>Made with <3 from Team Swing at MLH Prime 2016 Spring</p>' + '<img src=' + get_gif() + '></img>',
        from_email='email@email.100interns.com',
        subject='Thanks for stoping by!'
    )
    return 'Done'

@application.route('/out/<email>', methods=['GET'])
def send_out_email(email):
    print ('Sending Email Kicked')
    response = sp.transmissions.send(
        recipients=[email],
        html='<h3>Swing!</h3> <p>Someone beat your high score on the Swing board! Check the board at: http://bit.ly/2eUjp4g please come by our demo to reclaim your spot on the high scores!</p>' + '<p>Made with <3 from Team Swing at MLH Prime 2016 Spring</p>' + '<img src=' + get_gif_sad() + '></img>',
        from_email='email@email.100interns.com',
        subject='Oh! No! You have been beat!'
    )
    return 'Done'

if __name__ == "__main__":
    application.debug = True
    application.run()