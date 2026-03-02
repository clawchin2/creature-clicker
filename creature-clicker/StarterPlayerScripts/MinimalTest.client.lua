-- MinimalTest.client.lua
print("MINIMAL TEST START")
local player = game.Players.LocalPlayer
print("Got player: " .. tostring(player))
local gui = Instance.new("ScreenGui")
print("Created ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui", 10)
print("Parented to PlayerGui")
local label = Instance.new("TextLabel")
label.Text = "TEST UI WORKS"
label.Size = UDim2.new(0, 200, 0, 50)
label.Position = UDim2.new(0.5, -100, 0.5, -25)
label.Parent = gui
print("MINIMAL TEST COMPLETE")
