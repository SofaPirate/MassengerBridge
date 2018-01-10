class AsciiMassenger {

  java.lang.reflect.Method callback;
  byte[] receivedDataArray = new byte[1024];
  int receivedDataIndex = 0;
  Serial serial;
  Object instance;
  String callbackName;
  boolean ready = false;
  String address;
  int massageData;
  String[] words;
  int currentWord = 0;


  AsciiMassenger(Serial serial) {
    words = new String[0];
    this.serial = serial;
  }

  void attach( Object sketch, String callbackName ) {

    instance = sketch;

    try {
      callback = sketch.getClass().getMethod(callbackName );
    } 
    catch (ReflectiveOperationException e) {
      print("Could not find message callback "+callbackName+".");
      throw new RuntimeException(e);
    }
  }


  private void reset() {
    receivedDataIndex = 0;
    currentWord = 0;
    ready = false;
  }


  void process(int data) {


    if ( receivedDataIndex > 1023 ) {
      reset();
    }


    if ( data == 10 || data == 13 || data == 0 ) {

      if ( receivedDataIndex > 0 ) {

        String rawMassage = new String(receivedDataArray, 0, receivedDataIndex);
        words = splitTokens(rawMassage);
        ready = true;
        if ( words.length > 0 ) {
          address = words[0];
          currentWord++;
          if ( callback != null ) {
            try {
              callback.invoke(instance);
            } 
            catch (ReflectiveOperationException e) {
              print("Could not find massage received callback called "+callbackName+".");
              throw new RuntimeException(e);
            }
          }
        }
      }
      reset();
    } else if ( data > 31 && data < 128) {
      receivedDataArray[receivedDataIndex] = byte(data);
      receivedDataIndex++;
    }
  }

  private boolean isReady() {

    if ( ready && currentWord < words.length ) {
      return true;
    } else {
      return false;
    }
  }

  /*
  boolean checkString( String s) {
   if ( isReady() &&  words[currentWord].equals(s) ) {
   currentWord++;
   return true;
   }
   return false;
   }
   */
  int nextInt() {

    if ( isReady() ) {
      int data =  int(words[currentWord]);
      currentWord++;
      return data;
    }
    return 0;
  }

  float netFloat() {

    if ( isReady() ) {
      float data =  float(words[currentWord]);
      currentWord++;
      return data;
    }
    return 0;
  }
  String getAddress() {
    return address;
  }
}