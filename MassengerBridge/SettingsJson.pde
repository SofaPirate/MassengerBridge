

class SettingsJson {
  
  String filename;
  public JSONObject values; // first object
 

  
  SettingsJson( String jsonFile ) {
    filename = jsonFile;
    values = loadJSONObject(jsonFile);
    if ( values == null ) {
      println("SettingsJson : File not found");
      values = new JSONObject();
    } 
    
    
  }
  
  String getString( String key, String defaultValue ) {
    String s = values.getString(key,defaultValue);
    setString(key,s);
    return s;
  }
  
  void setString( String key, String value ) {
     values.setString(key,value);
  }
  
  int getInt( String key, int defaultValue ) {
    int i = values.getInt(key,defaultValue); 
    setInt(key,i);
    return i;
  }
  
   int getInt( String key, int defaultValue, int min, int max ) {
    int i = constrain(values.getInt(key,defaultValue),min,max); 
    setInt(key,i);
    return i;
  }
  
  void setInt ( String key , int value ) {
    values.setInt(key,value);
  }
  
  boolean getBoolean (String key, boolean defaultValue ) {
    boolean b = values.getBoolean(key,defaultValue); 
    setBoolean(key,b);
    return b;
  }
  
  void setBoolean( String key, boolean value ) {
     values.setBoolean(key,value);
  }
  
  void save() {
    saveJSONObject(values, filename);
   
    
  }
  
}