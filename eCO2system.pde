import processing.serial.*;
import gohai.simpletweet.*;
import twitter4j.Query;
import twitter4j.QueryResult;
import twitter4j.Status;
import twitter4j.TwitterException;
import twitter4j.User;
import cc.arduino.*;
import org.firmata.*;

SimpleTweet simpletweet;
ArrayList<Status> tweets;
Serial myPort, lcdPort;

int tn, tnold;

Arduino arduino;
 int relayPin=12;
 int ledPin=13;


void setup() {
  size(500, 500);
  //println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[1], 57600);
  arduino.pinMode(relayPin, Arduino.OUTPUT);
  arduino.pinMode(ledPin, Arduino.OUTPUT);
  arduino.digitalWrite (ledPin, Arduino.LOW);       
  arduino.digitalWrite (relayPin, Arduino.LOW);
  //
  simpletweet = new SimpleTweet(this);
  simpletweet.setOAuthConsumerKey("xxxx"); // replace xxxx with your OAuthConsumerKey
  simpletweet.setOAuthConsumerSecret("yyyy");  // replace yyyy with your OAuthConsumerSecret
  simpletweet.setOAuthAccessToken("zzzz");  // replace zzzz with your OAuthAccessToken
  simpletweet.setOAuthAccessTokenSecret("wwww");  // replace wwww with your OAuthAccessTokenSecret

  tweets = search("#StopClimateChange");
   
  String lcdportName = Serial.list()[0]; //change the 0 to a 1 or 2 etc. to match your port
  println(lcdportName);
  lcdPort = new Serial(this, lcdportName, 9600);
   
  tn=tweets.size();
  tnold=tweets.size();

}

void draw() {
  background(0);
  if (frameCount % 300 == 0) {
    thread("requestData");
  }
  
  String message = " ";
  String username=" ";
  int counter=0;
  if(tweets.size()>0) {
    counter=frameCount/50 % (tweets.size());
    Status current= tweets.get(0);
    message =current.getText();
    User user = current.getUser();
    username = user.getScreenName();
  }
  text(counter+" : "+message + " by @" + username, 0, height/2);
  lcdPort.write("#StopClimateChange by @"+username+"\n");
  delay(200);
  lcdPort.write(" ");

}

void requestData(){
    tnold=tn;
    tweets = search("#StopClimateChange");
    tn=tweets.size();
    if (tn>tnold){
    arduino.digitalWrite (ledPin, Arduino.HIGH);      
    arduino.digitalWrite (relayPin, Arduino.HIGH);    // relay activation
    delay(9000);
    arduino.digitalWrite (ledPin, Arduino.LOW);       
    arduino.digitalWrite (relayPin, Arduino.LOW);     // relay deactivation
    }
}


ArrayList<Status> search(String keyword) {
  // request 100 results
  Query query = new Query(keyword);
  query.setCount(100);

  try {
    QueryResult result = simpletweet.twitter.search(query);
    ArrayList<Status> tweets = (ArrayList)result.getTweets();
    // return an ArrayList of Status objects
    return tweets;
  } catch (TwitterException e) {
    println(e.getMessage());
    return new ArrayList<Status>();
  }
}
