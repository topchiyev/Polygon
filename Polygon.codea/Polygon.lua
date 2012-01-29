
Polygon = class()

function Polygon:init(points_, closed_, filled_, bordered_,
                    background_, borderColor_, borderWidth_)
    self.points = points_
    self.closed = closed_
    self.filled = filled_
    self.bordered = bordered_
    self.background = background_
    self.borderColor = borderColor_
    self.borderWidth = borderWidth_
end 
    
function Polygon:getBounds(points_)
    maxX = 0 - math.huge
    maxY = 0 - math.huge
    minX = math.huge
    minY = math.huge

    for i, pt in ipairs(points_) do
        if pt.x > maxX then
            maxX = pt.x
        end
        if pt.x < minX then
            minX = pt.x
        end
        if pt.y > maxY then
            maxY = pt.y
        end
        if pt.y < minY then
            minY = pt.y
        end
    end

    bounds = { vec2(minX, minY), vec2(maxX, maxY) }
    return bounds
end
    
function Polygon:draw()
    if self.filled then
        self:drawBackground()
    end
        
    if self.bordered then
        self:drawBorder()
    end
end

function Polygon:closePoints(points_)
    newPoints = {}
    for i, pt in ipairs(points_) do
        table.insert(newPoints, vec2(pt.x, pt.y))
    end
    pt1 = newPoints[1]
    pt2 = newPoints[table.maxn(newPoints)]
    if (pt1.x ~= pt2.x or pt1.y ~= pt2.y) then
        table.insert(newPoints, vec2(pt1.x, pt1.y))
    end
    return newPoints
end
    
function Polygon:drawBackground()
    self:fillPolygon(self:closePoints(self.points), self.background)
end
    
function Polygon:drawBorder()
    addPoint = false
    if (self.points[1].x ~= self.points[table.maxn(self.points)].x or
        self.points[1].y ~= self.points[table.maxn(self.points)].y) and
        self.closed then
        addPoint = true
    end
    
    outPoints = self:insetPoints(self:closePoints(self.points), -(self.borderWidth / 2))
    if addPoint then
        table.insert(outPoints, vec2(outPoints[1].x, outPoints[1].y))
    end
    
    inPoints = self:insetPoints(self:closePoints(self.points), (self.borderWidth / 2))
    if addPoint then
        table.insert(inPoints, vec2(inPoints[1].x, inPoints[1].y))
    end
    
    joinPoints = {}
    for i = 1, table.maxn(outPoints) do
        table.insert(joinPoints, vec2(outPoints[i].x, outPoints[i].y))
    end
    
    for i = 1, table.maxn(inPoints) do
        table.insert(joinPoints, 1, vec2(inPoints[i].x, inPoints[i].y))
    end
    table.insert(joinPoints, vec2(joinPoints[1].x, joinPoints[1].y))
    
    self:fillPolygon(joinPoints, self.borderColor)
end
    
function Polygon:simpleStrokeBorder(points_, width_, strokeColor_)
    pushStyle()
    smooth()
    stroke(strokeColor_)
    strokeWidth(width_)
    
    prevPt = nil;
    for i, pt in ipairs(points_) do
        if prevPt ~= nil then
            line(prevPt.x, prevPt.y, pt.x, pt.y)
        end
        prevPt = pt;
    end
    popStyle()
end
    
function Polygon:fillPolygon(points_, color_)
    oldPoints = points_
    points_ = {}

    for i, pt in ipairs(oldPoints) do
        x = math.floor(pt.x * (10 ^ 0) + 0.5) / (10 ^ 0)
        y = math.floor(pt.y * (10 ^ 0) + 0.5) / (10 ^ 0)
        table.insert(points_, vec2(x, y))
    end
    
    pushStyle()
    noSmooth()
    fill(color_)
    
    lPoligon = {}

    for i, pt in ipairs(points_) do
        table.insert(lPoligon, vec2(pt.x, pt.y))
    end

    sortedEdges = self:createEdges(lPoligon)

    -- sort all edges by y coordinate, smallest one first, lousy bubblesort
    tmp = nil

    for i = 1, table.maxn(sortedEdges) - 1 do --(int i = 0; i < sortedEdges.length - 1; i++)
        for j = 1 , table.maxn(sortedEdges) - 1 do --(int j = 0; j < sortedEdges.length - 1; j++)
            if sortedEdges[j].p1.y > sortedEdges[j+1].p1.y then 
                -- swap both edges
                tmp = sortedEdges[j];
                sortedEdges[j] = sortedEdges[j+1];
                sortedEdges[j+1] = tmp
            end
        end
    end

    -- find biggest y-coord of all vertices
    scanlineEnd = 0;
    for i, v in ipairs(sortedEdges) do -- (int i = 0; i < sortedEdges.length; i++)
        if scanlineEnd < sortedEdges[i].p2.y then
            scanlineEnd = sortedEdges[i].p2.y
        end
    end


    -- scanline starts at smallest y coordinate
    scanline = sortedEdges[1].p1.y

    -- this list holds all cutpoints from current scanline with the polygon
    list = {}

    -- move scanline step by step down to biggest one
    for scanline = sortedEdges[1].p1.y, scanlineEnd do
        list = {}

        -- loop all edges to see which are cut by the scanline
        for i = 1, table.maxn(sortedEdges) do

            -- here the scanline intersects the smaller vertice
            if scanline == sortedEdges[i].p1.y then
                if scanline == sortedEdges[i].p2.y then
                    -- the current edge is horizontal, so we add both vertices
                    sortedEdges[i]:deactivate()
                    table.insert(list, sortedEdges[i].curX)
                else
                    sortedEdges[i]:activate()
                    -- we don't insert it in the list cause this vertice is also
                    -- the (bigger) vertice of another edge and already handled
                end
            end

            -- here the scanline intersects the bigger vertice
            if scanline == sortedEdges[i].p2.y then
                sortedEdges[i]:deactivate()
                table.insert(list, sortedEdges[i].curX)
            end

            -- here the scanline intersects the edge, so calc intersection point
            if scanline > sortedEdges[i].p1.y and scanline < sortedEdges[i].p2.y then
                sortedEdges[i]:update()
                table.insert(list, sortedEdges[i].curX)
            end

        end

        -- now we have to sort our list with our x-coordinates, ascendend
        swaptmp = nil
        for i = 1, table.maxn(list) - 1 do
            for j = 1, table.maxn(list) - 1 do
                if list[j] > list[j+1] then
                    swaptmp = list[j]
                    list[j] = list[j+1]
                    list[j+1] = swaptmp
                end
            end
        end

        if (table.maxn(list) < 2 or table.maxn(list) % 2 ~= 0) == false then
            -- This should never happen!

            -- so draw all line segments on current scanline
            for i = 1, table.maxn(list) - 1 do
                if i % 2 == 1 and list[i] < list[i+1] then
                    rect(list[i] + 1, scanline, list[i+1] - list[i] - 1, 1);
                end
                
            end
        end
    end
    
    popStyle()

end
    
function Polygon:createEdges(points_)
    pt1 = points_[1]
    pt2 = points_[table.maxn(points_) - 1]
    if (pt1.x ~= pt2.x or pt1.y ~= pt2.y) then
        table.insert(points_, vec2(pt1.x, pt1.y))
    end

    sortedEdges = {}
    for i = 1, table.maxn(points_) - 1 do
        if points_[i].y < points_[i+1].y then
            sortedEdges[i] = Edge(points_[i], points_[i+1])
        else
            sortedEdges[i] = Edge(points_[i+1], points_[i])
        end
    end
    return sortedEdges
end

function Polygon:inset(dist_)
    newPoints = self:insetPoints(self:closePoints(self.points), dist_)
    self.points = newPoints
end

function Polygon:insetPoints(points_, dist_)
    newPoints = {}

    len = table.maxn(points_)
    for i = 1, len - 1 do
        pt = nil
        prevPt = nil
        nextPt = nil
        if i == 1 then
            prevPt = points_[len - 1]
            pt = points_[1]
            nextPt = points_[2]
        else
            prevPt = points_[i - 1]
            pt = points_[i]
            nextPt = points_[i + 1]
        end

        newPt = self:insetCorner(prevPt, pt, nextPt, dist_)
        if (newPt ~= nil) then
            table.insert(newPoints, newPt)
        end
    end

    return newPoints;
end
    
function Polygon:insetCorner(prevPt, curPt, nextPt, dist)
    a = prevPt.x b = prevPt.y
    c = curPt.x d = curPt.y
    e = nextPt.x f = nextPt.y

    c1 = c d1 = d c2 = c d2 = d
    dx1 = 0 dy1 = 0 dx2 = 0 dy2 = 0
    dist1 = 0 dist2 = 0 insetX = 0 insetY=0

    dx1=c-a dy1=d-b dist1=math.sqrt(dx1*dx1+dy1*dy1)
    dx2=e-c dy2=f-d dist2=math.sqrt(dx2*dx2+dy2*dy2)
        
    if (dist1 == 0 or dist2 == 0) then
        return nil
    end

    insetX= dy1/dist1*dist a=a+insetX c1=c1+insetX
    insetY=-dx1/dist1*dist b=b+insetY d1=d1+insetY
    insetX= dy2/dist2*dist e=e+insetX c2=c2+insetX
    insetY=-dx2/dist2*dist f=f+insetY d2=d2+insetY

    if (c1==c2 and d1==d2) then
        return vec2(c1,d1)
    end

    return self:lineIntersection(a,b,c1,d1,c2,d2,e,f)
end
    
function Polygon:lineIntersection(Ax, Ay, Bx, By, Cx, Cy, Dx, Dy)
    distAB, theCos, theSin, newX, ABpos = 0

    Bx = Bx - Ax
    By = By - Ay
    Cx = Cx - Ax
    Cy = Cy - Ay
    Dx = Dx - Ax
    Dy = Dy - Ay

    distAB=math.sqrt(Bx*Bx+By*By)

    theCos=Bx/distAB
    theSin=By/distAB
    newX=Cx*theCos+Cy*theSin
    Cy  =Cy*theCos-Cx*theSin Cx=newX
    newX=Dx*theCos+Dy*theSin
    Dy  =Dy*theCos-Dx*theSin Dx=newX

    if (Cy == Dy) then
        return nil
    end

    ABpos=Dx+(Cx-Dx)*Dy/(Dy-Cy)

    X=Ax+ABpos*theCos
    Y=Ay+ABpos*theSin

    return vec2(X,Y);
end
    
function Polygon:move(toPt)
    newPoints = {}
    bounds = self:getBounds(self.points)

    for i = 1, table.maxn(self.points) do
        pt = self.points[i]
        newPt = vec2(pt.x - bounds[1].x + toPt.x, pt.y - bounds[1].y + toPt.y)
        table.insert(newPoints, newPt)
    end

    self.points = newPoints
end

function Polygon:scale(scaleFactor_)
    newPoints = {}
    for i = 1, table.maxn(self.points) do
        pt = self.points[i]
        newPt = vec2(pt.x * scaleFactor_.x, pt.y * scaleFactor_.y)
        table.insert(newPoints, newPt)
    end
    self.points = newPoints
end

function Polygon:rotateByDegrees(degrees_, origin_)
    radians = (degrees_ * math.pi / 180)
    self:rotateByRadians(radians, origin_)
end

function Polygon:rotateByRadians(radians_, origin_)
    bounds = self:getBounds(self.points)

    if (origin_ == nil) then
        x = (bounds[1].x + ((bounds[2].x - bounds[1].x) / 2))
        y = (bounds[1].y + ((bounds[2].y - bounds[1].y) / 2))
        origin_ = vec2(x,y);
    end

    newPoints = {}

    for i = 1, table.maxn(self.points) do
        pt = self.points[i]
        x = (origin_.x + ((pt.x - origin_.x) * math.cos(radians_) - (pt.y - origin_.y) * math.sin(radians_)))
        y = (origin_.y + ((pt.x - origin_.x) * math.sin(radians_) + (pt.y - origin_.y) * math.cos(radians_)));
        table.insert(newPoints, vec2(x,y));
    end
    
    self.points = newPoints
end




Edge = class()
    
function Edge:init(a, b)
    self.p1 = vec2(a.x, a.y)
    self.p2 = vec2(b.x, b.y)
    self.m = ((self.p1.y - self.p2.y) / (self.p1.x - self.p2.x))
    self.curX = 0
end
    
function Edge:activate()
    self.curX = self.p1.x
end
    
function Edge:deactivate()
    self.curX = self.p2.x
end
    
function Edge:update()
    self.curX = self.curX + (1.0 / self.m)
end

