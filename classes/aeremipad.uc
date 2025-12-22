class aeremipad extends Decoration;
#exec mesh import mesh=aeremilaunchpad anivfile=Models\aeremilaunchpad_a.3d datafile=Models\aeremilaunchpad_d.3d x=0 y=0 z=0 mlod=0
#exec mesh origin mesh=aeremilaunchpad x=0 y=0 z=0
#exec mesh sequence mesh=aeremilaunchpad seq=All startframe=0 numframes=1
#exec meshmap new meshmap=aeremilaunchpad mesh=aeremilaunchpad
#exec meshmap scale meshmap=aeremilaunchpad x=0.07820 y=0.07820 z=0.15640

function TakeDamage(int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType){
   local aeremirocket t;
   foreach allactors(class'aeremirocket', t) t.trigger(none,none);
}

defaultproperties{
  bDirectional=true
  DrawType=DT_Mesh
  Mesh=Mesh'aeremilaunchpad'
  ScaleGlow=3.00000
  ambientglow=128.00000
  bCollideWhenPlacing=false
  bCollideActors=true
  bCollideWorld=false
  bBlockActors=true
  bBlockPlayers=true
  bStatic=false
  CollisionRadius=18.00000
  CollisionHeight=80.00000
  MultiSkins(0)=Texture'Mine.Trim.steel01'
  MultiSkins(1)=Texture'Mine.Base.MCMETL'
  MultiSkins(2)=Texture'Mine.Trim.MWARN2'
}
