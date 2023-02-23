intent('hello world', p => {
    p.play('(hello|hi there)');
});


intent('take me to $(PLACE* (.*))', p=>{
    let place = project.places.filter(x=> x.name.toLowerCase() === p.PLACE.toLowerCase() || x.short_name.toLowerCase() === p.PLACE.toLowerCase())[0];
    
    try{
        p.play({"command": "take_me_to", "id": place.id});
        p.play("(Please wait | On it | Okay Boss | Fetching direction)");
        
    }catch(err){
        console.log("I can't locate this place");
        p.play("Sorry, I can't locate this place");
    }
});

intent('i want to go to $(PLACE* (.*))', p=>{
    let place = project.places.filter(x=> x.name.toLowerCase() === p.PLACE.toLowerCase() || x.short_name.toLowerCase() === p.PLACE.toLowerCase())[0];
    
    try{
        p.play({"command": "take_me_to", "id": place.id});
        p.play("(Please wait | On it | Okay Boss | Fetching direction)");
        
    }catch(err){
        console.log("I can't locate this place");
        p.play("Sorry, I can't locate this place");
    }
});

intent('how do i get to $(PLACE* (.*))', p=>{
    let place = project.places.filter(x=> x.name.toLowerCase() === p.PLACE.toLowerCase() || x.short_name.toLowerCase() === p.PLACE.toLowerCase())[0];
    
    try{
        p.play({"command": "take_me_to", "id": place.id});
        p.play("(Please wait | Preparing your journey | Calculating your direction | Fetching direction)");
        
    }catch(err){
        console.log("I can't locate this place");
        p.play("Sorry, I can't locate this place");
    }
});
