// REQUIRES PROCESSING 3.0

import oscP5.*;
import netP5.*;


import java.util.Map;

OscP5 oscP5;
NetAddress myRemoteLocation;



int inPort;

SettingsJson settings;

HashMap<String, Message> dataReceived = new HashMap<String, Message>();

boolean showSourceIP;

String[] lastMessages;
int lastMessagesIndex =0;

float lineHeight = 15;

int lastRow;

int messagesByPattern;
int messagesByTime;


void settings() {
  settings = new SettingsJson("settings.json");
  messagesByPattern = settings.getInt("messagesByPattern", 10, 1, 50);
  messagesByTime = settings.getInt("messagesByTime", 10, 1, 50);

  size(400, int((messagesByPattern+messagesByTime+3)*lineHeight));
  noSmooth();
}

void setup() {

  lastMessages = new String[messagesByTime];
  for ( int i =0; i < lastMessages.length; i++ ) {
    lastMessages[i] = "";
  }

  frameRate(settings.getInt("frameRate", 10, 1, 120));

  inPort = settings.getInt("inPort", 12345, 1024, 65000);

  showSourceIP = settings.getBoolean("showSourceIP", false);

  myRemoteLocation = new NetAddress("127.0.0.1", 12000);

  oscP5 = new OscP5(this, inPort);

  settings.save();



  textAlign(LEFT, TOP);

  lastRow = int (height/lineHeight );
}


void draw() {
  //background(60);
  noStroke();
  fill(0);
  rect(0, rowY(0), width, rowY(1));
  fill(255);
  text("* LISTENING TO PORT : "+inPort+ " *", 5, rowY(0));

  float y = lineHeight*3;

  fill(255);
  rect(0, rowY(1), width, rowY(1));
  fill(0);
  text("LAST MESSAGES SORTED BY ADDRESS PATTERN : ", 5, rowY(1));

  fill(0);
  rect(0, rowY(2), width, rowY(messagesByPattern));


  int j = 0;
  // Using an enhanced loop to interate over each entry
  for (Map.Entry me : dataReceived.entrySet()) {
    Message m = (Message) me.getValue();

    int duration = constrain(millis() - m.startTime, 0, 10000);

    fill(   map(duration, 0, 10000, 255, 100)  );
    text(m.string, 5, rowY(j+2));
    j++;
  }


  fill(255);
  y = rowY(messagesByPattern+2);

  rect(0, y, width, rowY(1));
  fill(0);
  text("LAST MESSAGES RECEIVED BY ARRIVAL TIME : ", 5, y);

  fill(0);
  rect(0, rowY(messagesByPattern+3), width, rowY(messagesByTime));
  fill(255);

  for (int i = 0; i < lastMessages.length; i++) {
    String s = lastMessages[(lastMessagesIndex+i)%messagesByTime];
    fill(i/float(messagesByTime)*127+128);
    text(s, 5, rowY( messagesByTime + messagesByPattern + 3 - i - 1));
  }




  /*
  noStroke();
   ellipseMode(CENTER);
   float n = sin(frameCount*0.01)*300;
   fill(110, 255,220);  
   ellipse(width/2, height/2, n , n);
   */
  //println(frameCount+"\t"+String.format("%.2f", frameRate)+"\t"+String.format("%.2f", n));
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {

  String messageAddressPattern =  theOscMessage.addrPattern() ;

  String messageToString;
  if ( showSourceIP == false ) {
    messageToString =  messageAddressPattern;
  } else {
    messageToString =  theOscMessage.address() + "  " +messageAddressPattern;
  }

  Object[] arguments =  theOscMessage.arguments();
  for ( int i =0; i < arguments.length; i ++ ) {
    messageToString += " "+arguments[i].toString();
  }
  logDataReceived(messageAddressPattern, messageToString);
}


void logDataReceived(String key, String data) {


  dataReceived.put(key, new Message(data));

  if ( dataReceived.size() > messagesByPattern ) {
    // remove the oldest
    String oldest = "";
    int oldestDuration = -1;
    for (Map.Entry me : dataReceived.entrySet()) {
      Message m = (Message) me.getValue();

      int duration = constrain(millis() - m.startTime, 0, 10000);
      if ( duration >= oldestDuration ) {
        oldestDuration = duration;
        oldest = (String) me.getKey();
      }
    }
    dataReceived.remove(oldest);
  }
  
  
 

  lastMessages[lastMessagesIndex] = data;
  lastMessagesIndex = (lastMessagesIndex+1)%lastMessages.length;
}

float rowY(int row) {

  return row*lineHeight;
}