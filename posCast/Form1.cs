using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Threading;

namespace posCast
{
    public delegate bool MsgCallback(string msg);

    public partial class Form1 : Form
    {
        Worker Werker;
        Thread Draad;
        bool KeepRunning;

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            Text = "posCast 0.1";
            Werker = new Worker();
            Werker.cbError = onError;
            Werker.cbMessage = onMessage;
            Werker.cbStarted = onStarted;
            Werker.cbStarting = onStarting;
            Werker.cbStatus = onStatus;
            Werker.cbStopped = onStopped;
        }

        private void buStart_Click(object sender, EventArgs e)
        {
            Start();
        }

        private void Start()
        {
            if (Draad != null)
                return;
            Draad = new Thread(new ThreadStart(Werker.ThreadProc));
            Werker.ComPort = "com6:";
            Werker.Host = "bdb.dyndns.org";
            Werker.UDPPort = 1977;
            KeepRunning = true;
            Draad.Start();
        }

        private void buStop_Click(object sender, EventArgs e)
        {
            Stop();
        }

        private void Stop()
        {
            buStop.Enabled = false;
            onMessage("Stopping...");
            KeepRunning = false; // on first update, will return false to stop.
            Werker.KeepRunning = false;
        }

        private void tiReadSend_Tick(object sender, EventArgs e)
        {
        }

        private void buQuit_Click(object sender, EventArgs e)
        {
            Quit();
        }

        private void Quit()
        {
            Stop();
            try
            {
                if (Draad != null)
                    Draad.Join();
            }
            catch
            {
            }
            Close();
        }

        // This delegate enables asynchronous calls for setting
        // the text property on a TextBox control.
        delegate void SetTextCallback( string text);
        public void SetDebugText( string text)
        {
            if (laDebug.InvokeRequired)
            {
                SetTextCallback d = new SetTextCallback(SetDebugText);
                this.Invoke(d, new object[] { text });
            }
            else
                laDebug.Text = text;
        }
        public void SetDataText(string text)
        {
            if (laData.InvokeRequired)
            {
                SetTextCallback d = new SetTextCallback(SetDebugText);
                this.Invoke(d, new object[] { text });
            }
            else
                laData.Text = text;
        }

        delegate void EnableStartCallback(bool on);
        private void EnableStart(bool on)
        {
            if (buStart.InvokeRequired)
            {
                EnableStartCallback d = new EnableStartCallback(EnableStart);
                this.Invoke(d, new object[] { on });
            }
            else
                buStart.Enabled = on;
        }

        delegate void EnableStopCallback(bool on);
        private void EnableStop(bool on)
        {
            if (buStop.InvokeRequired)
            {
                EnableStopCallback d = new EnableStopCallback(EnableStop);
                this.Invoke(d, new object[] { on });
            }
            else
                buStop.Enabled = on;
        }

        private bool onMessage(string x)
        {
            SetDebugText(x);
            return KeepRunning;
        }

        private bool onStatus(string x)
        {
            SetDataText( x );
            return KeepRunning;
        }

        private bool onError(string x)
        {
            SetDebugText( "Error: " + x );
            return KeepRunning;
        }

        private bool onStarting(string x)
        {
            EnableStart(false);
            return KeepRunning;
        }

        private bool onStarted( string x )
        {
            EnableStop(true);
            return KeepRunning;
        }

        private bool onStopped( string x )
        {
            EnableStart(true);
            EnableStop(false);
            Draad = null;
            return KeepRunning;
        }

        private void menuItem1_Click(object sender, EventArgs e)
        {
            Quit();
        }

        private void menuItem2_Click(object sender, EventArgs e)
        {
            if (buStop.Enabled)
                Stop();
            else if (buStart.Enabled)
                Start();
        }

    }

}

namespace posCast
{
    class Worker
    {
        public string ComPort;
        public string Host;
        public int UDPPort;
        public MsgCallback cbStarted, cbError, cbMessage, cbStatus, cbStopped, cbStarting;

        public bool Start()
        {
            if (cbStarting != null)
                cbStarting(null);

            try
            {
                udp = new System.Net.Sockets.UdpClient();
                udp.Connect(Host, UDPPort);
                Message("UDP connected");
            }
            catch
            {
                Error("Failed to connect");
                udp = null;

                if (cbStopped != null)
                    KeepRunning = cbStopped(null);

                return false;
            }

            try
            {
                com = new System.IO.Ports.SerialPort();
                com.BaudRate = 4800;
                com.Parity = System.IO.Ports.Parity.None;
                com.StopBits = System.IO.Ports.StopBits.One;
                com.DataBits = 8;
                com.ReadBufferSize = 4096;
                com.ReadTimeout = 1500;
                com.PortName = ComPort;
                com.Open();
                Message("COM open");
            }
            catch
            {
                Error("Failed to open com");
                udp = null;
                com = null;

                if (cbStopped != null)
                    cbStopped(null);

                return false;
            }

            if (cbStarted != null)
                cbStarted("");

            KeepRunning = true;
            return true;
        }

        public void Message(string s)
        {
            if (cbMessage != null)
                KeepRunning = cbMessage(s);

        }

        public void Error(string s)
        {
            if (cbError != null)
                KeepRunning = cbError(s);

        }

        public void Status(string s)
        {
            if (cbStatus != null)
                KeepRunning = cbStatus(s);

        }

        private System.Net.Sockets.UdpClient udp;
        private System.IO.Ports.SerialPort com;
        public volatile bool KeepRunning;

        public void ThreadProc()
        {
            if (!Start())
                return;

            int s = 2048;
            byte[] Buffer = new byte[s];
            int tel = 0, total = 0;

            while (KeepRunning)
            {
                try
                {
                    int read = com.Read(Buffer, 0, s);
                    tel++;
                    total += read;
                    udp.Send(Buffer, read);
                    Status(tel.ToString() + " : " + total.ToString() + "( " + (total / tel).ToString() + " bpp)");
                }
                catch
                {
                    // TODO handle real (non timeout) exceptions
                }
            }
            if (cbStopped != null)
                cbStopped(null);
        }
    };
}