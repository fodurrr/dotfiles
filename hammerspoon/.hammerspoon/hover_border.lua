local M = {}

local hover_border = nil
local poll_timer = nil
local spaces_watcher = nil
local screen_watcher = nil

local last_window_id = nil
local last_frame_key = nil

local config = {
  poll_interval = 0.08,
  color = { hex = "#f9e2af", alpha = 1.0 },
  width = 6,
  corner_radius = 10,
  inset = 2,
}

local function frame_key(frame)
  return string.format("%d:%d:%d:%d", frame.x, frame.y, frame.w, frame.h)
end

local function expanded_frame(frame, inset)
  return hs.geometry.rect(frame.x - inset, frame.y - inset, frame.w + (inset * 2), frame.h + (inset * 2))
end

local function is_window_eligible(win)
  if not win then
    return false
  end
  if not win:isStandard() then
    return false
  end
  if win:isMinimized() then
    return false
  end
  if win:isFullScreen() then
    return false
  end
  if not win:screen() then
    return false
  end
  return true
end

local function window_under_mouse()
  local point = hs.mouse.absolutePosition()
  local windows = hs.window.orderedWindows()
  for _, win in ipairs(windows) do
    if is_window_eligible(win) then
      local frame = win:frame()
      if frame:contains(point) then
        return win
      end
    end
  end
  return nil
end

local function hide_border()
  if hover_border then
    hover_border:hide()
  end
  last_window_id = nil
  last_frame_key = nil
end

local function refresh_hover_border()
  local hovered = window_under_mouse()
  if not hovered then
    hide_border()
    return
  end

  local focused = hs.window.focusedWindow()
  if focused and hovered:id() == focused:id() then
    hide_border()
    return
  end

  local frame = expanded_frame(hovered:frame(), config.inset)
  local current_window_id = hovered:id()
  local current_frame_key = frame_key(frame)

  if current_window_id == last_window_id and current_frame_key == last_frame_key then
    return
  end

  hover_border:setFrame(frame)
  hover_border:show()
  last_window_id = current_window_id
  last_frame_key = current_frame_key
end

local function merge_config(user_config)
  if not user_config then
    return
  end
  for key, value in pairs(user_config) do
    config[key] = value
  end
end

function M.start(user_config)
  M.stop()
  merge_config(user_config)

  hover_border = hs.drawing.rectangle(hs.geometry.rect(0, 0, 1, 1))
  hover_border:setFill(false)
  hover_border:setStroke(true)
  hover_border:setStrokeColor(config.color)
  hover_border:setStrokeWidth(config.width)
  hover_border:setRoundedRectRadii(config.corner_radius, config.corner_radius)
  hover_border:setLevel(hs.drawing.windowLevels.overlay)
  hover_border:setBehaviorByLabels({ "canJoinAllSpaces", "stationary", "ignoresCycle" })
  hover_border:hide()

  poll_timer = hs.timer.doEvery(config.poll_interval, refresh_hover_border)

  if hs.spaces and hs.spaces.watcher then
    spaces_watcher = hs.spaces.watcher.new(function()
      hide_border()
    end)
    spaces_watcher:start()
  end

  screen_watcher = hs.screen.watcher.new(function()
    hide_border()
  end)
  screen_watcher:start()

  refresh_hover_border()
end

function M.stop()
  if poll_timer then
    poll_timer:stop()
    poll_timer = nil
  end
  if spaces_watcher then
    spaces_watcher:stop()
    spaces_watcher = nil
  end
  if screen_watcher then
    screen_watcher:stop()
    screen_watcher = nil
  end
  if hover_border then
    hover_border:delete()
    hover_border = nil
  end
  last_window_id = nil
  last_frame_key = nil
end

return M
