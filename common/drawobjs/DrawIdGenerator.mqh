#include <Generic\HashMap.mqh>;


int id = 0;


CHashMap<int, string>  nameMap2;

/*

   on draw line ->  getId 0,1,2,3
   on draw start -> reset to 0???
*/


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string findNameId(string name)
  {
   if(nameMap2.ContainsKey(id))
     {
      /*name already exists
        delete old name then add new name
      */
      string oldName;
      nameMap2.TryGetValue(id, oldName);

      // bool result = ObjectDelete(0, oldName);
      if(! ObjectDelete(0, oldName))
        {
         Print("failed to delete  " + oldName + ": " +  ObjectDelete(0, oldName));
        }


     }

   return generateId() + name;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string generateId()
  {
   string name = getName(id);
   id++;
   return name;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getName(int id)
  {
   return id+"@@ ";
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void onDrawEnd()
  {
   int total =  ObjectsTotal(0);
   //Print("onDrawEnd last id is " + id);
   nameMap2.Clear();
//StringFind

//for every object it end with @@ and proceeded with space
//get the number after @@
//if number
   for(int i=0;i<ObjectsTotal(0);i++)
     {
      string name  = ObjectName(0,i);

   
      string pos = StringFind(name, "@@", 0);
      int nameId = 0; //12

      for(int j=0; j<pos;j++)
        {
         string c = CharToString(StringGetCharacter(name, j));
         int posId = StringToInteger(c);
         nameId = nameId*10 + posId;
        }
      // Print("object name: " + name + " id: " + nameId );
      if(nameId>=id)
        {
         nameMap2.Remove(nameId);
         // Print("deleting: " + name );
         ObjectDelete(0, name);
        }
      else
        {
         // Print("Adding: " + name );
         nameMap2.Add(nameId, name);
        }
     }

   /* while(ObjectFind(0,getName(id))>=0){
       ObjectDelete(0 , getName(id) );
       id++;
    }*/

   int keys[];
   string values[];
   nameMap2.CopyTo(keys, values);
   string info = "";
   for(int i=0;i< ArraySize(keys) ; i++)
     {
      info+=i+" ";
     }

   id = 0;
  // Print("OKOKOK hashmap: "  + info);
  }
