Background = class()

BACKGROUND_TYPE_COLOR = 1
BACKGROUND_TYPE_GRADIENT = 2
BACKGROUND_TYPE_IMAGE = 3

IMAGE_MODE_CENTER = 1
IMAGE_MODE_STRETCH = 2
IMAGE_MODE_PROPORTIONAL_STRETCH = 3
IMAGE_MODE_REPEAT = 4

function Background:init(filler_, mode_or_angle)
    self.filler = filler_
    self.type = nil
    self.mode = nil
    self.angle = nil
    
    
    if filler_ ~= nil then
        if filler_.r ~= nil then
            self.type = BACKGROUND_TYPE_COLOR
        elseif type(filler_) == "table" and table.maxn(filler_) > 1 and filler_[1].r ~= nil then
            self.type = BACKGROUND_TYPE_GRADIENT
            self.angle = mode_or_angle
            
            resColor = self:getGradientColor(100, 0, self.filler[1], self.filler[2])
            print("gcolor= ", resColor)
            resColor = self:getGradientColor(100, 25, self.filler[1], self.filler[2])
            print("gcolor= ", resColor)
            resColor = self:getGradientColor(100, 50, self.filler[1], self.filler[2])
            print("gcolor= ", resColor)
            resColor = self:getGradientColor(100, 75, self.filler[1], self.filler[2])
            print("gcolor= ", resColor)
            resColor = self:getGradientColor(100, 100, self.filler[1], self.filler[2])
            print("gcolor= ", resColor)
        
        elseif filler_.width ~= nil then
            self.type = BACKGROUND_TYPE_IMAGE
            self.mode = mode_or_angle
        end
    end
    
end

function Background:getColor(point, bounds)
    if self.type == BACKGROUND_TYPE_COLOR then
        return self.filler
    elseif self.type == BACKGROUND_TYPE_GRADIENT then
        width = bounds[2].x - bounds[1].x
        position = point.y - bounds[1].x
        color1 = self.filler[1]
        color2 = self.filler[2]
        resColor = self:getGradientColor(width, position, color1, color2)
        return resColor
    end
end


function Background:getGradientColor(width, position, color1, color2)

    r = color1.r / 255
    g = color1.g / 255
    b = color1.b / 255
        
    dr = ((color2.r / 255) - r) / width
    dg = ((color2.g / 255) - g) / width
    db = ((color2.b / 255) - b) / width

    r = (r + (dr * position)) * 255
    g = (g + (dg * position)) * 255
    b = (b + (db * position)) * 255
    
    
        
    return color(r,g,b,255)
end

