module sleekui.jface.window.DesktopWindow;

import dwt.widgets.Display;
import dwt.widgets.Shell;
import dwt.widgets.Tray;
import dwtx.jface.window.ApplicationWindow;

abstract class DesktopWindow : ApplicationWindow
{
    this()
    {
        this(null);
    }

    this(Shell shell)
    {
        super(shell);
    }

    void run()
    {
        setBlockOnOpen(true);
        open();
        Display.getCurrent().dispose();
    }

    void create()
    {
        super.create();
        createTrayIcon(getShell().getDisplay().getSystemTray());
    }

    protected void createTrayIcon(Tray tray)
    {
    }
}
