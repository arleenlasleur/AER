class AerGr_light extends Effects;

function timer(){
   local weapon w;
   if(instigator == none) return;
   w = instigator.weapon;
   if(w == none) return;
   if(!w.isa('aerwpn')){
     LightType = LT_None;
     bHidden = true;
   }
}

function beginplay(){
   setTimer(0.3,true);
}

defaultproperties{
  DrawType=DT_None
//  bHidden=false
  LightBrightness=255
  LightHue=173
  LightSaturation=200
  LightCone=150
  LightEffect=LE_Spotlight
  LightRadius=17
  LightType=LT_None
//  bStatic=false
//  bNoDelete=false
}
