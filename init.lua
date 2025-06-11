


function Thievery_SingleDelayer(delay, timeElapsed, elapsedThreshhold, delayFrame, cycleFunk, endFunk)
    delayFrame:SetScript("OnUpdate", function(self, elapsed)
        timeElapsed = timeElapsed + elapsed
        if timeElapsed > elapsedThreshhold then
            if cycleFunk then
                if cycleFunk() == true then
                    --print("Breaking delayer")
                    self:SetScript("OnUpdate", nil)
                    return
                end
            end
            delay = delay - timeElapsed
            timeElapsed = 0
        end
        
        if delay <= 0 then
            self:SetScript("OnUpdate", nil)
            endFunk()
            return
        end
    end)
end