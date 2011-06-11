module woot.WootWatcher;

import woot.WootClient;
import woot.WootItem;
import woot.WootWatchThread;

class WootWatcher
{
    alias void delegate(WootItem) WootItemUpdateDg;
    alias void delegate(Exception) WootExceptionDg;
    protected WootWatchThread worker;

    this(WootClient.WootType type)
    {
        this(new WootWatchThread(type));
    }
    
    package this(WootWatchThread worker)
    {
        this.worker = worker;
    }

    void start()
    {
        worker.start();
    }

    void stop()
    {
        worker.stop();
    }

    void refresh()
    {
        worker.notify();
    }

    void bindWootUpdated(WootItemUpdateDg dg)
    {
        worker.wootUpdated.attach(dg);
    }

    void unbindWootUpdated(WootItemUpdateDg dg)
    {
        worker.wootUpdated.detach(dg);
    }

    void bindWootError(WootExceptionDg dg)
    {
        worker.wootError.attach(dg);
    }

    void unbindWootError(WootExceptionDg dg)
    {
        worker.wootError.detach(dg);
    }
}

debug
{
    unittest
    {
        auto thread = new FakeWootWatchThread(new FakeWootClient, WootClient.Woot);
        auto watcher = new WootWatcher(thread);

        watcher.bindWootUpdated((WootItem item) {
            assert(item !is null);
        });

        watcher.start();
        thread.join();
    }
}
