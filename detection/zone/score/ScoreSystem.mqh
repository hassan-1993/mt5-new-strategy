//+------------------------------------------------------------------+
//|                                                  ScoreSystem.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "../Zone.mqh";
#include "../support/MoveStrength.mqh";
#include "./BreakDetector.mqh";


// Helper struct: first field = score so ArraySort can sort by it
class ZoneData: public CObject {
   public: double  score;
   public: Zone  *obj;

   public: ZoneData(Zone *obj, double score){
      this.obj = obj;
      this.score = score;
   }

   virtual  int Compare(const CObject *node, const int mode=0) const {
         const ZoneData *other = (const ZoneData*) node;
         if(score > other.score) return -1; // this comes before o
         if(score < other.score) return +1; // this comes after o
         return 0;                                     // equal
   }  
};



CArrayObj* sort(CArrayObj* list){
   CArrayObj* zoneDataList = new CArrayObj();

   for(int i=0;i<list.Total();i++){
       Zone* obj = list.At(i);
       double score = findScores(obj);
       ZoneData* data = new ZoneData(obj, score);
       zoneDataList.Add(data);
    }

    zoneDataList.Sort();
    
    
    for(int i=0;i<zoneDataList.Total(); i++){
       ZoneData* data = zoneDataList.At(i);
       
    }

   return zoneDataList;
}


CArrayObj* filterOutWeakScores(CArrayObj* zones){
  
  CArrayObj* zoneDataList = sort(zones);
  

  /*
  *  must be above average
  *  sum all scores up to 80% only
  *
  */
  string scores_info = "";
  string selected_scores_info = "";
  double total = 0;
  for(int i=0;i<zoneDataList.Total();i++){
     ZoneData* data = zoneDataList.At(i);
     scores_info+= " " + data.score;
     total+=data.score;
  }

  double average = total/ zoneDataList.Total();
  double max_80 = total* 0.8;
  double current = 0;

  CArrayObj* filteredList = new CArrayObj();

  for(int i=0;i<zoneDataList.Total();i++){
     ZoneData* data = zoneDataList.At(i);

     if(data.score<average) break;
     current+=data.score; 
     
     if(current>=max_80) break; //if reach at least 80%

     //above average and sum of still below 80% -> take it
     filteredList.Add(data);
     selected_scores_info+= " " + data.score ;
  }

   return filteredList;
}



double score(Zone* obj, int touchIndex){
    ZoneTouchInfo* touchPoint = obj.touchInfos.At(touchIndex);
     
    //reaction 
    double move_reaction = MoveStrength::findTouchPointMove(obj, touchIndex);
    
    //broken points
    BreakDetectionParams *params = new BreakDetectionParams(0,0);
    int totalBroken  = CountBreaksForTouchPoint(touchPoint, params);
    totalBroken  = CountBreaksForTouchPoint(touchPoint, params);
    
    double decay_rate = 0.6; //smaller -> more aggressive
    
    double totalScore = move_reaction * MathPow(decay_rate, totalBroken);
    
    return totalScore;
}


double findScores(Zone* obj){

  double total_score = 0;
  for(int i=0; i<obj.Total(); i++){
    ZoneTouchInfo* touchPoint = obj.touchInfos.At(i);
   
    double point_score = score(obj, i);
    total_score += point_score;
  }
  
  /*totalBroken -> every broken -> lose 30%*/
  return NormalizeDouble(total_score,4);
}




