class AerSN_blood extends SpawnNotify;

simulated event Actor SpawnNotification(Actor A){
    local int Num;
    local Actor Other;
    foreach RadiusActors(ActorClass, Other, 14, A.Location)
        if(Other!=A && ++Num>2) Other.Destroy();
    return A;
}

defaultproperties{
        ActorClass=Class'UnrealShare.BloodSplat2'
        bHidden=True
}
