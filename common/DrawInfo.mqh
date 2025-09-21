//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "./Utils.mqh";
//#include "./data/Level.mqh";
#include <Arrays\ArrayObj.mqh>;
//#include <Arrays\ArrayInt.mqh>;
#include <Arrays\ArrayInt.mqh>;
//#include "./patterns/TriangleS.mqh";

#include "./drawObjs/DrawIdGenerator.mqh";
#include "../detection/zone/ZoneStore.mqh";
#include "../detection/zone/Zone.mqh";

input bool isDraw = false;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawLine(string name, double x1, double y1, double x2, double y2, color clrValue = clrRed, int size = 3)
  {
   string n = findNameId(name);
   int line = ObjectCreate(0,n, OBJ_TREND, 0, x1, y1, x2, y2);
   ObjectSetInteger(0, n, OBJPROP_COLOR, clrValue);
   ObjectSetInteger(0, n,  OBJPROP_WIDTH, size);

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void arrowUp(string name, double time, double price, color colorValue)
  {
   string nameId = findNameId(name);
   ObjectCreate(0, nameId, OBJ_ARROW, 0, time, price);
   ObjectSetInteger(0, nameId, OBJPROP_COLOR, colorValue);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void arrowDown(string name, double time, double price, color colorValue)
  {
   string nameId = findNameId(name);
   double pip = pipValue();
   double y = price+9*pip;
   ObjectCreate(0, nameId, OBJ_ARROW_DOWN, 0, time, y);
   ObjectSetInteger(0, nameId, OBJPROP_COLOR, colorValue);
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawWaves(string name, CArrayInt& list, color clr, int size=3)
  {
   if(!isDraw)
      return;

   string debugData = "";
   for(int j=0;j<list.Total(); j++)
     {
      debugData+=list.At(j) + " ";
     }
   for(int j=0;j<list.Total(); j++)
     {
      if(j-1>=0)
        {
         int lowA = list.At(j);
         int highB = iHighest(Symbol(),Period(),MODE_HIGH,lowA-list.At(j-1)+1,list.At(j-1));
         drawLine(name + " " + debugData, time(lowA), low(lowA), time(highB), high(highB),clr,size);
        }

      if(j+1<list.Total())
        {
         int lowA = list.At(j);
         int highB = iHighest(Symbol(),Period(),MODE_HIGH,list.At(j+1)-lowA+1,lowA);
         drawLine(name + " " + debugData, time(lowA), low(lowA), time(highB), high(highB),clr,size);
        }

     }

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawAllWaves(CArrayInt& lists[], string name = "bear", int seed = 0)
  {
   if(!isDraw)
      return;
   color colors[] = { clrWhite,clrBlue, clrPink, clrTeal,
                      clrMediumSpringGreen, clrDeepSkyBlue, clrMaroon, clrDeepPink
                    };

   int size = ArraySize(colors);
   int amount = seed%size;
// ObjectsDeleteAll(0,name);
   for(int i=ArraySize(lists)-1;i>=0; i--)
     {

      CArrayInt trend = lists[i];
      int ff = trend.Total();
      if(trend.Total()>0)
        {

         int index = amount%size;
         color clr = colors[index];
         for(int j=0;j<trend.Total(); j++)
           {
            int size = MathMax(4, 6-amount*3);
            drawWaves("", trend, clr, size);
            id++;
           }
         amount++;
        }
     }
  }











//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawLows(string name, int& lows[],  color clr = clrWhite)
  {
   for(int i=0;i<ArraySize(lows);i++)
     {
      arrowUp(name + " low:" + " " + lows[i], time(lows[i]), low(lows[i]), clr);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawHighs(string name, int& highs[], color clr = clrWhite)
  {
   for(int i=0;i<ArraySize(highs);i++)
     {
      arrowDown(name + " high:" + " " + highs[i], time(highs[i]), high(highs[i]), clr);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawLows(string name, CArrayInt& lows,  color clr = clrWhite)
  {
   for(int i=0;i<lows.Total();i++)
     {
      arrowUp(name + " low:" + " " + lows.At(i), time(lows.At(i)), low(lows.At(i)), clr);
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawHighs(string name, CArrayInt& highs,  color clr = clrWhite)
  {
   for(int i=0;i<highs.Total();i++)
     {
      arrowDown(name + " high:" + " " + highs.At(i), time(highs.At(i)), high(highs.At(i)), clr);
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawInfo(string name, int& lows[], int& highs[], color color_low, color color_high, int& exclude_list[])
  {
   if(!isDraw)
      return;
   for(int i=0;i<ArraySize(highs);i++)
     {

      arrowDown(name + " high:" + " " + highs[i], time(highs[i]), high(highs[i]), color_high);
     }

   for(int i=0;i<ArraySize(lows);i++)
     {
      if(contains(exclude_list, lows[i]))
         continue;
      arrowUp(name + " low:" + " " + lows[i], time(lows[i]), low(lows[i]), color_low);
     }
  }


void drawPoints(string name, int& arr[], int mode, color color_arr, int modeType = -1)
  {
   if(!isDraw)
      return;

   for(int i=0;i<ArraySize(arr);i++)
     {
      double price;

      if(modeType == MODE_CLOSE){
         price = close(arr[i]);
      }else if(mode == MODE_LOW){
         price = low(arr[i]);
      }else if(mode == MODE_HIGH){
         price = high(arr[i]);
      }
   

      if(mode == MODE_LOW){
          arrowUp(name + " low:" + " " + arr[i], time(arr[i]), price, color_arr);
      }else if(mode == MODE_HIGH){
          arrowDown(name + " high:" + " " + arr[i], time(arr[i]), price, color_arr);
      }
      
     }
  }
  
  
  
  void drawTouchPoints(string name, CArrayObj& arr, color color_arr)
  {
   if(!isDraw)
      return;

   for(int i=0;i<arr.Total();i++)
     {
       TouchPoint* point =  arr.At(i);
       double price = point.price();
       
       
      if(point.mode == MODE_LOW){
          arrowUp(name + " low:" + " " + point.candleIndex, time(point.candleIndex), price, color_arr);
      }else if(point.mode == MODE_HIGH){
          arrowDown(name + " high:" + " " + point.candleIndex, time(point.candleIndex), price, color_arr);
      }
      
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawRectangle(string name, double fromX, double toX, double fromY, double toY, uint col = -1)
  {


   if(col == -1){
      col = ColorToARGB(clrYellow, 240);
   }
   
//ObjectCreate(0,"RECTANGLE_LABEL",OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectCreate(0,name,OBJ_RECTANGLE,0, fromX, fromY, toX, toY);
   ObjectSetInteger(0,name,OBJPROP_COLOR,col);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR, col);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,3);
   ObjectSetInteger(0,name,OBJPROP_FILL,true);


  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawLabel(string name, int x, int y, string label, color clr = clrRed)
  {
   ObjectCreate(0, name, OBJ_LABEL, 0, time(2), high(2));

   ObjectSetString(0,name,OBJPROP_TEXT,label);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name, OBJPROP_COLOR, clr);

  }




void drawZone(string name, Zone& zone,  uint col =  -1){
    if(!isDraw) return;
    string nameId = findNameId(name);
    double fromX = time(1500);
    double toX = time(0);
    double minPrice = zone.min_price;
   
    
    double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    
    double maxPrice = MathMax(zone.max_price, zone.min_price + tick_size*20);
     
    drawRectangle(nameId, fromX, toX, minPrice, maxPrice, col);
}