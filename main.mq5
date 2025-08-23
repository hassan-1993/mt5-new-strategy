
#include "./strategy/TestZones.mqh"
#include "./common/drawobjs/DrawIdGenerator.mqh"

void OnTick(void){
    testing();
    int total = ObjectsTotal(0, -1, -1);
    total = total;
    Print("total is " + total );
    onDrawEnd();
}


int OnInit(void){
   return INIT_SUCCEEDED;
}