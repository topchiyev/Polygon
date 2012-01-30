
models = {}

function setup()
    
    star = {
        vec2(0, 60),
        vec2(30, 60),
        vec2(40, 90),
        vec2(50, 60),
        vec2(80, 60),
        vec2(55, 45),
        vec2(70, 15),
        vec2(40, 35),
        vec2(15, 15),
        vec2(25, 45)
    }
    table.insert(models, star)
        
    box = {
        vec2(0, 0),
        vec2(0, 70),
        vec2(70, 70),
        vec2(70, 0)
    }
    table.insert(models, box)
        
    spin = {
        vec2(0, 30),
        vec2(30, 60),
        vec2(35, 55),
        vec2(10, 30),
        vec2(30, 10),
        vec2(50, 30),
        vec2(40, 40),
        vec2(30, 30),
        vec2(35, 25),
        vec2(30, 20),
        vec2(20, 30),
        vec2(40, 50),
        vec2(60, 30),
        vec2(30, 0)
    }
    table.insert(models, spin)
        
    complex = {
        vec2(0,0),
        vec2(0,30),
        vec2(30,60),
        vec2(70,60),
        vec2(70,50),
        vec2(80,50),
        vec2(80,30),
        vec2(90,30),
        vec2(90,20),
        vec2(60,30),
        vec2(50,30),
        vec2(80,10),
        vec2(80,0),
        vec2(40,0),
        vec2(40,20),
        vec2(20,20),
        vec2(50,50),
        vec2(30,50),
        vec2(10,30),
        vec2(10,10),
        vec2(30,10),
        vec2(30,0)
    }
    table.insert(models, complex)
        
    m_shape = {
        vec2(0,0),
        vec2(0,50),
        vec2(25,25),
        vec2(50,50),
        vec2(50,0)
    }
    table.insert(models, m_shape)
    
    triangle = {
        vec2(0,0),
        vec2(0, 100),
        vec2(100, 0)
    }
    table.insert(models, triangle)
    
    iparameter("PositionX", 0, WIDTH, WIDTH/2)
    iparameter("PositionY", 0, HEIGHT, HEIGHT/2)
    iparameter("Angle", 0, 360, 0)
    parameter("Scale", 1, 20, 1)
    iparameter("Inset", -20, 20, 0)
    iparameter("Model", 1, table.maxn(models), 2)
    
    curPositionX = PositionX
    curPositionY = PositionY
    curAngle = curAngle
    curScale = curScale
    curModel = curModel
    curInset = curInset
    
    polygon = Polygon()
    polygon.closed = true
    polygon.filled = true
    polygon.bordered = true
    color(0, 255, 0)
    polygon.background = Background({color(0, 255, 0), color(0, 0, 255)}, 0)
    polygon.border = Background(color(255, 0, 0, 255))
    polygon.borderWidth = 6
end

function draw()
    background(0, 0, 0)
    
    if curModel ~= Model then
        curModel = Model
        polygon.points = models[curModel]
        curPositionX = nil
        curPositionY = nil
        curAngle = nil
        curScale = nil
        curInset = nil
    end
    
    if curScale ~= Scale and Scale ~= 0 then
        if curScale == nil then
            curScale = Scale
        else
            curScale = 1 / curScale * Scale
        end
        polygon:scale(vec2(curScale, curScale))
        curScale = Scale
    end
    
    if curInset ~= Inset then
        if curInset == nil then
            curInset = Inset
        else
            curInset = curInset - Inset
        end
        polygon:inset(curInset)
        curInset = Inset
    end
    
    if curPositionX ~= PositionX or curPositionY ~= PositionY then
        curPositionX = PositionX
        curPositionY = PositionY
        polygon:move(vec2(curPositionX, curPositionY))
    end
    
    if curAngle ~= Angle then
        if curAngle == nil then
            curAngle = Angle
        else
            curAngle = Angle - curAngle
        end
        polygon:rotateByDegrees(curAngle, screenCenter)
        curAngle = Angle
    end
    
    polygon:draw()
end
