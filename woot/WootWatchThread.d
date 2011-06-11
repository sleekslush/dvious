module woot.WootWatchThread;

import tango.core.Signal;
import tango.core.Thread;
import tango.core.sync.Condition;
import tango.core.sync.Mutex;
import woot.WootClient;
import woot.WootItem;

class WootWatchThread : Thread
{
    Signal!(WootItem) wootUpdated;
    Signal!(Exception) wootError;
    protected bool isActive = true;
    protected Mutex mutex;
    protected Condition condition;
    protected WootClient client;
    protected WootClient.WootType type;

    this(WootClient.WootType type)
    {
        super(&run);
        mutex = new Mutex;
        condition = new Condition(mutex);
        client = new WootClient;
        this.type = type;
    }

    void stop()
    {
        isActive = false;
        notify();
    }

    void notify()
    {
        synchronized(mutex) {
            condition.notify();
        }
    }

    protected void run()
    {
        do {
            try {
                wootUpdated(client.getWoot(type));
            } catch (Exception ex) {
                wootError(ex);
            }

            synchronized(mutex) {
                condition.wait(600);
            }
        } while (isActive);
    }
}

debug
{
    package class FakeWootWatchThread : WootWatchThread
    {
        private this(WootClient.WootType type)
        {
            super(type);
        }

        this(WootClient client, WootClient.WootType type)
        {
            this(type);
            this.client = client;
        }

        void stop()
        {
        }

        void notify()
        {
        }

        protected void run()
        {
            wootUpdated(client.getWoot(type));
        }
    }

    unittest
    {
    }
}
