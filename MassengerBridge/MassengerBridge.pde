import processing.serial.*;

// REQUIRES PROCESSING 3.0

import oscP5.*;
import netP5.*;


import java.util.Map;

OscP5 oscP5;
NetAddress myRemoteLocation;



int inPort;

SettingsJson settings;



boolean showSourceIP;

  float lineHeight = 15;

Logger netLogger;
Logger serialLogger;

void settings() {
  settings = new SettingsJson("settings.json");
  int messagesByPattern = settings.getInt("messagesByPattern", 10, 1, 50);
  int messagesByTime = settings.getInt("messagesByTime", 10, 1, 50);
  inPort = settings.getInt("inPort", 12345, 1024, 65000);
  
  int w = 400;
  int h = int((messagesByPattern+messagesByTime+3)*lineHeight)*2;
  
  size(w,h);
  noSmooth();
  
  netLogger = new Logger(0,h*0.5,h*0.5,messagesByPattern,messagesByTime,lineHeight);
  netLogger.header = "NET PORT : "+inPort;
  
  serialLogger =  new Logger(0,0,h*0.5,messagesByPattern,messagesByTime,lineHeight);
  serialLogger.header = "SERIAL PORT : ";
}

void setup() {

  frameRate(settings.getInt("frameRate", 10, 1, 120));



  showSourceIP = settings.getBoolean("showSourceIP", false);

  myRemoteLocation = new NetAddress("127.0.0.1", 12000);

  oscP5 = new OscP5(this, inPort);

  settings.save();

  
}


void draw() {
 netLogger.draw();
 serialLogger.draw();
 
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
  netLogger.log(messageAddressPattern, messageToString);
}