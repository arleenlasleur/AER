class AerSN_trail extends SpawnNotify;  // works like shit, seems impossible

simulated event Actor SpawnNotification(Actor A){
    local int Num;
    local Actor Other;
    foreach RadiusActors(ActorClass, Other, 80, A.Location)
        if(Other!=A && ++Num>4) Other.Destroy();
    return A;
}

defaultproperties{
        ActorClass=Class'AER.AerGr_trail_bullet'
        bHidden=True
}
