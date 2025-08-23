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


void findScores(Zone* obj){

  for(int i=0; i<obj.Total(); i++){
    ZoneTouchInfo* touchPoint = obj.touchInfos.At(i);
    
    int candle_index = touchPoint.candleIndex();
    
    if(candle_index<467 && candle_index>465){
         int ok = 0;
    }
    
    double move_reaction = MoveStrength::findTouchPointMove(obj, i);
    move_reaction = move_reaction;
    
    BreakDetectionParams *params = new BreakDetectionParams(0,0);
    int totalBroken  = CountBreaksForTouchPoint(touchPoint, params);
    totalBroken  = CountBreaksForTouchPoint(touchPoint, params);
    
    
    int brokenScore = totalBroken * 0.4 * move_reaction;
    int finalScore = MathMax(0, move_reaction  - brokenScore);
  }
  
  /*totalBroken -> every broken -> lose 30%*/
}

