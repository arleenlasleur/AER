class AerGr_FI extends Info;
var font SavedFont;

function font GetCanvasFont(){
   if(SavedFont != None) return SavedFont;
   SavedFont = GetStaticFont();
   return SavedFont;
}

static function font GetStaticFont(){
   return Font(DynamicLoadObject("AER.aerfontbig", class'Font'));
}

defaultproperties{
   SavedFont=None
}
