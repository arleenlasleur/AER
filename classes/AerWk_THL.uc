// =============================================
// Translator history list, ported from olextras
// =============================================
class AerWk_THL expands Actor;
var aerwk_thl next;
var aerwk_thl prev;
var translatorevent msg_targ;

function aerwk_thl add(translatorevent new_targ){
   prev = spawn(class,owner);
   prev.next = self;
   prev.msg_targ = new_targ;
   return prev;
}

function remove(){
  if(next != none) next.prev = prev;
  if(prev != none) prev.next = next;
  prev = none;
  destroy(); // 2024-12-06: save mem, todo test whether this not produce more bugs.
}

function aerwk_thl process(translatorevent new_targ){
   local aerwk_thl hist;
   if(new_targ=='' || new_targ==none) return self;
   if(prev != none)   return prev.process(new_targ);
   for(hist=self; hist!=none; hist=hist.next)
      if(hist.msg_targ == new_targ) break;
   if(hist == self)   return self;
   if(hist == none)   return add(new_targ);
   hist.remove();
   hist.next = self;
   prev = hist;
   return hist;
}

defaultproperties{
   Next=None
   Prev=None
   msg_targ=none
   RemoteRole=ROLE_None
   bHidden=true
}
