class Logger {


  HashMap<String, Message> dataReceived = new HashMap<String, Message>();

  String[] lastMessages;
  int lastMessagesIndex =0;



  int lastRow;

  int messagesByPattern;
  int messagesByTime;
  float lineHeight;
  
  public String header = "Logger";
  
  float x,y;

  Logger(float x, float y, float w, int messagesByPattern, int messagesByTime, float lineHeight) {
    lastMessages = new String[messagesByTime];
    for ( int i =0; i < lastMessages.length; i++ ) {
      lastMessages[i] = "";
    }
    lastRow = int (height/lineHeight );
    
    this.messagesByPattern = messagesByPattern;
    this.messagesByTime = messagesByTime;
    this.lineHeight = lineHeight;
    this.x = x;
    this.y = y;
    
  }


  void draw() {
    textAlign(LEFT, TOP);
    noStroke();
    
    pushMatrix();
    translate(x,y);

    
    fill(0);
    rect(0, rowY(0), width, rowY(1));
    fill(255);
    text(header, 5, rowY(0));

    float y = lineHeight*3;

    fill(255);
    rect(0, rowY(1), width, rowY(1));
    fill(0);
    text("SORTED BY ADDRESS PATTERN : ", 5, rowY(1));

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
    text("SORTED BY ARRIVAL TIME : ", 5, y);

    fill(0);
    rect(0, rowY(messagesByPattern+3), width, rowY(messagesByTime));
    fill(255);

    for (int i = 0; i < lastMessages.length; i++) {
      String s = lastMessages[(lastMessagesIndex+i)%messagesByTime];
      fill(i/float(messagesByTime)*127+128);
      text(s, 5, rowY( messagesByTime + messagesByPattern + 3 - i - 1));
    }
    
    popMatrix();
  }

  void log(String key, String data) {


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
}