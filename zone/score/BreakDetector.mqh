

#include "../Zone.mqh";
#include "../ZoneStore.mqh";


class BreakDetectionParams
{
   // end bar index (inclusive). If <= startBar or invalid => scan to Bars-1
   public: int     end_candle_index;   // absolute bar index (position), NOT a range length
   public: double  buf;              // small buffer (e.g., Point); 0 for strict

   // Constructor with defaults
   public: BreakDetectionParams(int e = 0, double b = 0.0)
   {
      end_candle_index = e;
      buf     = b;
   }
};


int CountBreaksForTouchPoint(ZoneTouchInfo &tp,   BreakDetectionParams &p)
{
 
   const int    startBar = tp.candleIndex();
   const double level    = tp.price();

   // decide scan end (absolute index, inclusive)
   int endBar = p.end_candle_index;
   

   if(level<130.6 && level> 130.5){ 
       int bb = 0;
   }

   int  breaks = 0;
   bool broken = false;

   if(tp.mode == MODE_LOW) // demand: count closes BELOW level
   {
      for(int i = store.sortedPoints.Total()-1; i >= endBar; i--)
      {
         TouchPoint* point = store.sortedPoints.At(i);
         double candle_index =point.candleIndex(); 
         if(candle_index>= startBar) continue;
      //   if(candle_index<= store.THRESHOLD_BROKEN_IGNORE_RECENT_CANDLES) continue; 
         
         double c = MathMin(close(candle_index), open(candle_index));
         if(!broken)
         {
            if(c < level - p.buf) { 
            broken = true; 
            }
         }
         else
         {
            if(point.mode == MODE_HIGH && c > level + p.buf) { 
                 ++breaks; 
                broken = false;
             }
         }
      }
      return breaks;
   }
   else if(tp.mode == MODE_HIGH) // supply: count closes ABOVE level
   {
      for(int i = store.sortedPoints.Total()-1; i >= endBar; i--)
      {
         TouchPoint* point = store.sortedPoints.At(i);
         double candle_index =point.candleIndex();
         if(candle_index>= startBar) continue;
       //  if(candle_index<= store.THRESHOLD_BROKEN_IGNORE_RECENT_CANDLES) continue;
         
         double c = MathMax(close(candle_index), open(candle_index));
         if(!broken)
         {
            if(c > level + p.buf) {
              broken = true; 
             }
         }
         else
         {
            if(point.mode == MODE_LOW &&  c < level - p.buf) {
              ++breaks;
             broken = false; 
            }
         }
      }
      return breaks;
   }

   // unexpected mode
    return 0;
}