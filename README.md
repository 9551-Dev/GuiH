# **GuiH -simple documentation**
### info
	GuiH is my work in progress computercraft GUI api
	i made it in like a week trying to get usable performance and nice usage
download: `wget run https://github.com/9551-Dev/Gui-h/raw/main/installer.lua`


#
### features
		

 - **Core**
	 - core features are the ones used to actually run the API
	 since the api allows custom objects it provides you with
	 an api to create them this api is really simple and will be documented later
	 theese include
	   - automatic file handling
	   - automatic update handling
	   - automatic child GUI processing,position correcting
	   - grabbing events
	   - texture wrapping
	   - and more...
	 
	
 - **Gui**
	 - this is going to be about the current objects the api comes with and short description
	 - first of i need to note that all the function take in tables as inputs. all the values are optional
	 but you should provide key ones like name and position  by default
	 the actuall usage will be discussed later with the  arguments included
	 - input functions: some build in objects provide you with "event functions"
	 theese functions get called at specific times and might be useful !
	 
	- each one of theese has a texture support via the `tex` input variable

	- buttons and switches have support for the text and tex_on input
	for theese you input  the text object which gets create via 
	your GUI object in the text function. more on that later of course
	
	- types of build in objects
		- `button`  > a simple button that runs the on_click function when clicked
		- `switch` > similiar to a button. swich keeps its value and flips it on click
		-  `progressbar` > i mean.. it kinda says it. its an progress bar
			theese bars have 4 direction support !
		- `frame` frames kinda act like windows/tabs. you can use of their event functions
		to make use of them as an dragger for example !, they store they own window and you
		can move them around by dragging defined dragger


	- sure 4 default objects isnt much but you can make your own, i will also add more :P
	- if you made an object and want it to be added by default ping me on discord

#
# **basic usage**
### so here i will talk about the basics and concepts of the api instead of showing much code

- when your GuiH install finishes you are gonna get a new folder called GuiH
this is the APIs folder dont touch it ! running the files will have it crash anyways

- this api only works when required propperly you you update the api by running GuiH/installer.lua

- if you want to add custom objects you need to put  their folder into the objects folder in GuiH
i will go over the object structure later..

### usage
to use the api you have to require its main.lua  file	
this will give you 2 functions. load_texture and create_gui. the usage of theese function is
```lua
require("GuiH.main") -> API
```
```lua
API.create_gui(terminal object: table) -> GUI_OBJECT
```
```lua
API.load_texture(nimg path: string / nimg_data: table) -> GUI_TEXTURE
```

your create_gui function will need a terminal object. if you use term i highly reccomend to use term.current()
it will return a GUI_OBJECT which is an table that consists of a few main things
- the  `create` table (consists functions to create new objects)
- the `gui` table (has all the existing objects saved in it)
- the `text` function (creation of text objects)
- the `visible` boolean (sets if this object should be visible)
- and the updatee function (used to update your GUI and yield for events)

#
**USAGE OF CREATE**

- the create table is what you are gonna be using to create your objects.
it is used like this
```lua
GUI_OBJECT.create.<name>(input: table) -> GUI_BUTTON
```
so  for example
```lua
GUI_OBJECT.create.button({
	name="shutdown_button",
	x=1,y=1,width=3,height=3,
	background_color = colors.lime,
	on_click=function(object)
		os.shutdown()
	end
}) -> GUI_BUTTON
```
this will make a green button at 1,1 with w,h 3 that will shut the pc down when pressed

theese functions return their own object they just create but you can access them using the `gui` table
```lua
GUI_OBJECT.gui.<type>.<name> -> GUI_ELEMENT_OBJECT
```
#
**USAGE OF UPDATE**

the update function is used to actuall make you GUI work by well... updating its data and states/graphics
the functions has 4 arguments but you dont wanna touch the last 2. those are used internally for reccursive objects

but if you are intressted you can make custom event handler by setting is_child to true and inputting your
event in to the data variable. it needs to be processed with the GUI_OBJECT.convert_event function
```lua
GUI_OBJECT.convert_event(event_name,event1,event2,event3) -> DATA_EVENT
```
```lua
GUI_OBJECT.update([timeout: number_any,visible: boolean,is_child: boolean,data: table])
```
if no arguments are provided this function will yield until it gets an event
if you want to just update it wihnout waiting so graphic side shows up you can do
```lua
GUI_OBJECT.update(0)
```
this will be an example with our previous shutdown button code and what i usualy use
```lua
<GUI object definitions>
local function update_thread()
	GUI_OBJECT.update(0) --loads the textures imidietly on load
	while true do
		GUI_OBJECT.update() --listens for events and updates the actuall GUI
	end
end
local function code_main()
	--your other code
end
parallel.waitForAll(update_thread,code_main)
```
this is pretty good way to update your GUI

#
# OBJECT DOCUMENTATION

here i will be showing how diffirent objects act and what inputs  they should have
first lets set some basics if i say POS i mean you should have 4 values in it x,y,width,height
note that XY is always relative to the object you are writing it into. not the terminal
all arguments are optional but some objects might not work wihnout them

all objects also need a name ! 2 objects of the same type cant have a same name

also when i say BASE i mean things theese things
```css
btns:LUT -table setting what button clicks to react to
react_to_events:LUT -what events should this react to (dont change)
visible:BOOL -should this object be drawn
reactive:BOOL -should this object be responsive
```

if you see object written inside a function it probably means the object self so it can edit its own data.

## **text**
this object is special since it cant be drawn/generated with the create table
instead it gets made using the GUI_OBJECT.text  function
text can be used by other function to be displayed. text object stores various usefull text data

```css
text:STRING 		-the text on this text object
centered:BOOL		-should this text be centered
x:NUMBER 			-x cordinate
y:NUMBER 			-y cordinate
offset_x:NUMBER 	-offset on the x cordinate, useful for controling centering
offset_y:NUMBER 	-offset on the y cordinate, useful for controling centering
blit:TABLE 			-table that stores the colors for the text
blit table style: key 1 == text_color:STRING,key 2 == background_color:STRING
```

## **button**
a button as we talked about earlier is an simple object that runs the on_execute event function when
clicked, theese  buttons can be textured as most things there using nimg images
arguments
```css
name:STRING 							-name of this object in memory
POS:NUMBERS 							-stores the location data of this object
BASE:BASE								-basic object data
on_click:EVENT_FUNCTION(object,event)	-function executed when button gets clicked
background_color:NUMBER 				-color of the button or bg of the texture
text_color:NUMBER 						-color of text if any used
symbol:STRING 							-what symbol to draw with
tex:GUI_TEXTURE							-texture placed on the object
text:GUI_TEXT							-what text should be drawn on the button
```
-> BUTTON_ELEMENT


## **switch**
switch is basically the same as an button but it keeps its state so you can read it and do whatever you want
it has the advantage it can me turned on/off and use diffirent textures for those states
```css
name:STRING 									-name of this object in memory
POS:NUMBERS 									-stores the location data of this object
BASE:BASE										-basic object data
background_color:NUMBER 						-color of the button or bg of the texture
background_color_on:NUMBER 						-color of the button or bg of the texture when on
text_color:NUMBER 								-color of text if any used
text_color:NUMBER 								-color of text if any used when on
symbol:STRING 									-what symbol to draw with
tex:GUI_TEXTURE									-texture placed on the object
tex:GUI_TEXTURE									-texture placed on the object when on
text:GUI_TEXT									-what text should be drawn on the button
text_on:GUI_TEXT								-what text should be drawn on the button when on
on_change_state:EVENT_FUNCTION(object,event)	-called when switch changes state
value:BOOL										-the state of the switch
```
-> SWITCH_ELEMENT

## **progressbar**
progress bars are a great way to show state/progress in your program thats why  i added simple
textured progress bars
progress bars can have 4 dirrections
"left-right", "right-left", "bottom-top", "top-bottom"

```css
name:STRING 				-name of this object in memory
POS:NUMBERS 				-stores the location data of this object
BASE:BASE					-basic object data
fg:NUMBER_COLOR				-color of the filled up area (foreground)
bg:NUMBER_COLOR				-color of the empty area (background)
tex:GUI_TEXTURE				-texture to put on the filled progress bar
direction:PB_DIRECTION		-what way should the progress bar move in
value:NUMBER_PERCENT		-how many percent 0-100 should the bar be filled
```
-> PROGRESSBAR_ELEMENT

## **frame**
frames are very nice for creating a lot of things ! since they can be customised a lot
you can use them to make OS like windows/tabs,sliders movable buttons and movable term windows
super simply !

```css
name:STRING 									-name of this object in memory
POS:NUMBERS 									-stores the location data of this object
BASE:BASE										-basic object data
dragger:DRAGGER_ELEMENT:table					-the dragging field definition for the frame
dragged:BOOL									-says if the object is currently dragged
dragable:BOOL									-sets if this object can be dragged at all
on_move:EVENT_FUNCTION(object,new_pos:vector)	-happens when frame changes position
on_any:EVENT_FUNCTION(object,event)				-called every frame updates
on_select:EVENT_FUNCTION(object,event)			-called when you start dragging a frame
on_graphic:EVENT_FUNCTION(object)				-called in  the graphic stage
```
DRAGGER_ELEMENT

 - dragger element is its own POS element but its relative to the window you are currently setting it to
```css
	{
		x:NUMBER 		-the x value from the left top corner of the frame,
		y:NUMBER 		-the y value from the left top corner of the frame,
		width:NUMBER 	-width of this dragger
		height:NUMBER	-height of this dragger
	}
```

### on_move EVENT  function
	this function is special in the fact that if you have it return true
	it will not have the frame run its own interated move function
	which gives you full control over the movement

	for example this is an on_move function that will prevent the frame
	from being pushed out the screen
	
```lua
	function(object,pos)
        local term = object.canvas.term_object
        local w,h = term.getSize()
        object.window.reposition(
            math.max(
                math.min(
                    pos.x+object.positioning.width,
                    w+1
                )-object.positioning.width,1
            ),
            math.max(
                math.min(
                    pos.y+object.positioning.height,
                    h+1
                )-object.positioning.height,1
            )
        )
        return true
    end
   ```
	

-> FRAME_ELEMENT
frame element has 2 key values. those are the `window` and `child` values
window is just its own term object inside the frame!
so you can do
```lua
FRAME_WINDOW.write("test")
```
acts as any generic terminal element
what the child is its the frames own GUI_OBJECT you can use its create functions to write into
you dont need ot update it. update for its parrent object handles it
which is pretty epic :D



# **SIMPLE  OBJECT  API  EXPLANATION**

every object has 3 main files
	
 - object.lua
 - logic.lua
 - graphic.lua

all of theese files have their base that they need to work.
```lua
<object.lua base>
return function(object,input_data)
    local btn = {
        name=input_data.name or "",
        visible=(input_data.visible ~= nil) and input_data.visible or true,
        reactive=(input_data.reactive ~= nil) and input_data.reactive or true,
        react_to_events={}, --a look up table with the event names
        --btn={} --optional LUT table with the keys this object should respond to
    }
    return btn
end
```
```lua
<control.lua base>
return function(object,event)
end
```
```lua
<graphic.lua base>
return function(object)
end
```

first thing is that you need to make your object.lua which is gonna be what you are gonna use to
build the actuall GUI object

then logic.lua of all files gets called once that finishes graphic.lua of all files gets called
no need to handle visibility checking and reactivity checking yourselfs. the core api handles that for you

if you need to access the terminal the object is on you can do
```lua
	local term = object.canvas.term_object
```

you can also read all the data from the object.

the event you get in theh control section will be diffirent depending on what type of event you are checking for

here is an table with what the event will have depending on the event that happened

|event-output table|name:|e1|e2|e3
|--|--|--|--|--|
|monitor_touch|name=name|monitor|x|y
|mouse_click/mouse_up|name=name|button|x|y
|mouse_drag|name=name|button|x|y
|mouse_scroll|name=name|direction|x|y



# **oh well i think this is the end. i hope you like my API :D**


