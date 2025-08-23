
string fullMessage;


void addLog(string message, bool newLine = true){
   if(newLine){
      fullMessage+="\n ";
   }
    fullMessage+=message;
}


void clearLogs(){
  fullMessage = "";
}


void newLine(){
   fullMessage+"\n";
}

void printLogs(){
   Comment(fullMessage);
}