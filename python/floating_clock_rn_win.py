"""
Floating Digital Clock for Windows 11
-------------------------------------
A FREE transparent floating clock widget displaying time in 12-hour format.

Features:
- Always on top
- Draggable interface
- AM/PM indicator
- Double-click to close
- Transparent background
- Date display with shadow effect

Installation:
pip install pyinstaller
pyinstaller --onefile --noconsole --name RogerFloatingClock floating_clock_win_rn.py

Created by: Roger Nem
First version: May 2025
Version: 1.0
"""

import tkinter as tk
from datetime import datetime

class FloatingClock:
    def __init__(self):
        self.root = tk.Tk()
        
        # Basic window setup with transparency
        self.root.overrideredirect(True)
        self.root.attributes('-topmost', True)
        self.root.configure(bg='black')
        self.root.attributes('-transparentcolor', 'black')
        self.root.wm_attributes('-alpha', 1.0)
        
        # Main container
        self.container = tk.Frame(self.root, bg='black')
        self.container.pack(padx=5)
        
        # Time blocks container
        self.time_frame = tk.Frame(self.container, bg='black')
        self.time_frame.pack()
        
        # Date canvas for shadow effect
        self.date_canvas = tk.Canvas(
            self.time_frame,
            height=30,
            bg='black',
            highlightthickness=0
        )
        self.date_canvas.grid(row=0, column=0, columnspan=2, pady=(0, 5))
        
        # Hour block
        self.hour_canvas = tk.Canvas(
            self.time_frame,
            width=110,
            height=110,
            bg='black',
            highlightthickness=0
        )
        self.hour_canvas.grid(row=1, column=0, padx=3)
        
        # Minute block
        self.minute_canvas = tk.Canvas(
            self.time_frame,
            width=110,
            height=110,
            bg='black',
            highlightthickness=0
        )
        self.minute_canvas.grid(row=1, column=1, padx=3)
        
        # Configure grid to center date
        self.time_frame.grid_columnconfigure(0, weight=1)
        self.time_frame.grid_columnconfigure(1, weight=1)
        
        # Bind dragging events
        for widget in [self.container, self.date_canvas, self.time_frame,
                      self.hour_canvas, self.minute_canvas]:
            widget.bind('<Button-1>', self.start_drag)
            widget.bind('<B1-Motion>', self.drag)
            widget.bind('<Double-Button-1>', lambda e: self.root.destroy())
        
        self.update_clock()
    
    def draw_date(self, text):
        self.date_canvas.delete('all')
        width = 230
        self.date_canvas.configure(width=width)
        
        # Draw very subtle shadow first
        self.date_canvas.create_text(
            width/2 + 1,
            15 + 1,
            text=text,
            font=('Segoe UI', 12, 'bold'),
            fill='#333333',
            anchor='center'
        )
        
        # Draw main white text
        self.date_canvas.create_text(
            width/2,
            15,
            text=text,
            font=('Segoe UI', 12, 'bold'),
            fill='white',
            anchor='center'
        )
    
    def draw_block(self, canvas, text, is_minutes=False):
        canvas.delete('all')
        
        width = 110
        height = 110
        radius = 12
        
        # Draw main block
        canvas.create_rectangle(
            radius, 0,
            width-radius, height,
            fill='#101010', outline='#101010'
        )
        canvas.create_rectangle(
            0, radius,
            width, height-radius,
            fill='#101010', outline='#101010'
        )
        
        for x, y, start in [(0, 0, 90), (width-radius*2, 0, 0),
                           (0, height-radius*2, 180), (width-radius*2, height-radius*2, 270)]:
            canvas.create_arc(
                x, y, x+radius*2, y+radius*2,
                start=start, extent=90,
                fill='#101010', outline='#101010'
            )
        
        # Draw time
        canvas.create_text(
            width/2,
            height/2,
            text=text,
            font=('Arial Narrow', 55, 'bold'),
            fill='white',
            anchor='center'
        )
        
        # Draw AM/PM for minutes block
        if is_minutes:
            ampm = datetime.now().strftime('%p')  # Uppercase
            
            # Position and size for AM/PM indicator
            ampm_width = 30
            ampm_height = 16
            ampm_radius = 4
            ampm_x = width - ampm_width - 3  # Moved more to the right
            ampm_y = height - ampm_height - 8  # Moved more to the bottom
            
            # Draw AM/PM rounded rectangle
            canvas.create_rectangle(
                ampm_x + ampm_radius, ampm_y,
                ampm_x + ampm_width - ampm_radius, ampm_y + ampm_height,
                fill='#101010', outline='#101010'
            )
            canvas.create_rectangle(
                ampm_x, ampm_y + ampm_radius,
                ampm_x + ampm_width, ampm_y + ampm_height - ampm_radius,
                fill='#101010', outline='#101010'
            )
            
            # Draw rounded corners for AM/PM
            for x, y, start in [
                (ampm_x, ampm_y, 90),
                (ampm_x + ampm_width - ampm_radius*2, ampm_y, 0),
                (ampm_x, ampm_y + ampm_height - ampm_radius*2, 180),
                (ampm_x + ampm_width - ampm_radius*2, ampm_y + ampm_height - ampm_radius*2, 270)
            ]:
                canvas.create_arc(
                    x, y, x + ampm_radius*2, y + ampm_radius*2,
                    start=start, extent=90,
                    fill='#101010', outline='#101010'
                )
            
            # Draw AM/PM text
            canvas.create_text(
                ampm_x + ampm_width/2,
                ampm_y + ampm_height/2,
                text=ampm,
                font=('Segoe UI', 9),
                fill='white',
                anchor='center'
            )
    
    def start_drag(self, event):
        self.x = event.x_root - self.root.winfo_x()
        self.y = event.y_root - self.root.winfo_y()
    
    def drag(self, event):
        x = event.x_root - self.x
        y = event.y_root - self.y
        self.root.geometry(f'+{x}+{y}')
    
    def update_clock(self):
        now = datetime.now()
        
        # Update date with shadow effect
        self.draw_date(now.strftime('%A, %B %d, %Y'))
        
        # Update time
        hour = now.strftime('%I')
        minute = now.strftime('%M')
        
        # Draw time blocks
        self.draw_block(self.hour_canvas, hour, False)
        self.draw_block(self.minute_canvas, minute, True)
        
        # Schedule next update
        self.root.after(1000, self.update_clock)

if __name__ == '__main__':
    clock = FloatingClock()
    
    # Try to round the window corners (Windows 11)
    try:
        from ctypes import windll, byref, sizeof, c_int
        DWMWA_WINDOW_CORNER_PREFERENCE = 33
        DWM_WINDOW_CORNER_PREFERENCE = 2
        windll.dwmapi.DwmSetWindowAttribute(
            windll.user32.GetParent(clock.root.winfo_id()),
            DWMWA_WINDOW_CORNER_PREFERENCE,
            byref(c_int(DWM_WINDOW_CORNER_PREFERENCE)),
            sizeof(c_int)
        )
    except:
        pass
    
    clock.root.mainloop()
