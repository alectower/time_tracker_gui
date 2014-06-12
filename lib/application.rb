require 'rubygems' # disable this for a deployed application
require 'hotcocoa'

class TimeTracker
  include HotCocoa

  def start
    @app = application name: 'TimeTracker', delegate: self
    set_tray_items
    @app.run
  end

  def set_tray_items
    @menu = menu do |main|
      main.item :track_time, on_action: proc { track_time }
      main.item :set_project_and_task, on_action: proc { display_project_and_task }
      main.item :quit, on_action: proc { NSApp.terminate nil }
    end

    @tray_item = status_item image: create_image(:redColor), menu: @menu
  end

  def create_image(color)
    image = NSImage.new
    image.size = NSMakeSize(20.0,  20.0)
    image.lockFocus

    rect = NSMakeRect(5, 3, 10, 10)
    circlePath = NSBezierPath.bezierPath
    circlePath.appendBezierPathWithOvalInRect rect

    NSColor.blackColor.setStroke
    NSColor.send(color).setFill

    circlePath.stroke
    circlePath.fill

    image.unlockFocus

    image.drawAtPoint NSMakePoint(0.0, 0.0),
                fromRect: rect,
                operation: NSCompositeSourceOver,
                fraction: 1.0
    image
  end

  def display_project_and_task
    @window ||= window(:frame => [2000, 1510, 450, 80], :title => "Time Tracker", :view => :nolayout) do |win|
      win.will_close { win.orderOut nil}
      win.releasedWhenClosed = false

      win.view = layout_view(:layout => {:expand => [:width, :height],
                                         :padding => 0, :margin => 0}) do |vert|
        vert << layout_view(:frame => [0, 0, 0, 35], :mode => :horizontal,
                            :layout => {:padding => 0, :margin => 0,
                                        :start => false, :expand => [:width]}) do |horiz|

          horiz << label(:text => "Project", :layout => {:align => :center})
          horiz << @project_field = text_field(:text => '', :layout => {:expand => [:width]})
          horiz << label(:text => "Task", :layout => {:align => :center})
          horiz << @task_field = text_field(:text => '', :layout => {:expand => [:width]})

          horiz << button(:title => 'Set', :layout => {:align => :center}) do |b|
            b.on_action { set_project_and_task }
          end
        end
      end
    end
    if @project
      @project_field.stringValue = @project
    end
    if @task
      @task_field.stringValue = @task
    end
    @window.makeKeyAndOrderFront nil
    @window.setLevel NSStatusWindowLevel
  end


  def set_project_and_task
    @project = @project_field.stringValue
    @task = @task_field.stringValue

    project_title = "Project: #{@project}"
    task_title = "Task: #{@task}"

    if @project_menu_item
      @project_menu_item.title = project_title
    else
      @project_menu_item = @menu.item project_title
    end

    if @task_menu_item
      @task_menu_item.title = task_title
    else
      @task_menu_item = @menu.item task_title
    end

    @window.orderOut nil
  end

  def track_time
    project_task = "#{@project}:#{@task}"
    message = `time_tracker track #{project_task}`
    message[0] = message[0].upcase

    if message =~ /off/i
      @tray_item.image = create_image(:redColor)
    else
      @tray_item.image = create_image(:greenColor)
    end

    if @status_item
      @status_item.title = message
    else
      @status_item = @menu.item message
    end
  end

  def exit
    exit
  end

  # file/open
  def on_open(menu)
  end

  # file/new
  def on_new(menu)
  end

  # help menu item
  def on_help(menu)
  end

  # This is commented out, so the minimize menu item is disabled
  #def on_minimize(menu)
  #end

  # window/zoom
  def on_zoom(menu)
  end

  # window/bring_all_to_front
  def on_bring_all_to_front(menu)
  end
end

TimeTracker.new.start
