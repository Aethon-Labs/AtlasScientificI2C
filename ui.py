import os
from guizero import App, Text, TextBox, PushButton, ButtonGroup, Window, Picture, Box, info, yesno, error


class SutroUI():
    def __init__(self, name):
        self.APP_VERSION="1.0.0"
        self.device_name = name
        self.app = None
        self.focus_box = None
        self.pin_box = None
        self.blocking = False
        self.unlocked = False
        self.transaction_approved = False
        self.communication_channel = "Bluetooth"
        self.raw_transaction = None


    def is_blocking(self):
        return self.blocking

    def is_unlocked(self):
        if self.unlocked:
            self.unlocked = False
            return True
        return False

    def show_ui(self):
        self.app = App(title="Sutro Testing Application", width=480, height=320) 
        self.app.on_close(self.exit)
        self.dashboard()
        self.app.display()
    
    
    def dashboard(self):
        dashboard_box = Box(self.app, layout='grid')
        Picture(dashboard_box, image="sutro.png",grid=[2,0])
        PushButton(dashboard_box, text='pH Level', command=calculate, args=[99], grid=[1,2], width=10, height=1).text_size=15
        PushButton(dashboard_box, text='ORP', command=calculate, args=[98], grid=[2,2], width=10, height=1).text_size=15
        PushButton(dashboard_box, text='Temperature', command=calculate, args=[100], grid=[3,2], width=10, height=1).text_size=15
        pHVal = Text(dashboard_box, text='_ _ _ _', grid=[1,4], size=25)  
        orpVal = Text(dashboard_box, text='_ _ _ _', grid=[2,4], size=25)  
        tempVal = Text(dashboard_box, text='_ _ _ _', grid=[3,4], size=25)  
        

    def exit(self):
        os.system('kill '+str(os.getpid()))

    def shutdown(self):
        os.system('sudo shutdown now')

def calculate(self):
   pass
ui = SutroUI("Sutro")
ui.show_ui()
