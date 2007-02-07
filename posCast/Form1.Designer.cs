namespace posCast
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;
        private System.Windows.Forms.MainMenu mainMenu1;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.mainMenu1 = new System.Windows.Forms.MainMenu();
            this.menuItem1 = new System.Windows.Forms.MenuItem();
            this.miStartStop = new System.Windows.Forms.MenuItem();
            this.buStart = new System.Windows.Forms.Button();
            this.buStop = new System.Windows.Forms.Button();
            this.laDebug = new System.Windows.Forms.Label();
            this.laData = new System.Windows.Forms.Label();
            this.buQuit = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // mainMenu1
            // 
            this.mainMenu1.MenuItems.Add(this.menuItem1);
            this.mainMenu1.MenuItems.Add(this.miStartStop);
            // 
            // menuItem1
            // 
            this.menuItem1.Text = "Quit";
            this.menuItem1.Click += new System.EventHandler(this.menuItem1_Click);
            // 
            // miStartStop
            // 
            this.miStartStop.Text = "Start";
            this.miStartStop.Click += new System.EventHandler(this.menuItem2_Click);
            // 
            // buStart
            // 
            this.buStart.Location = new System.Drawing.Point(3, 3);
            this.buStart.Name = "buStart";
            this.buStart.Size = new System.Drawing.Size(234, 46);
            this.buStart.TabIndex = 0;
            this.buStart.Text = "Start";
            this.buStart.Click += new System.EventHandler(this.buStart_Click);
            // 
            // buStop
            // 
            this.buStop.Enabled = false;
            this.buStop.Location = new System.Drawing.Point(3, 55);
            this.buStop.Name = "buStop";
            this.buStop.Size = new System.Drawing.Size(234, 46);
            this.buStop.TabIndex = 1;
            this.buStop.Text = "Stop";
            this.buStop.Click += new System.EventHandler(this.buStop_Click);
            // 
            // laDebug
            // 
            this.laDebug.Location = new System.Drawing.Point(0, 248);
            this.laDebug.Name = "laDebug";
            this.laDebug.Size = new System.Drawing.Size(237, 20);
            this.laDebug.Text = ".";
            // 
            // laData
            // 
            this.laData.Location = new System.Drawing.Point(0, 228);
            this.laData.Name = "laData";
            this.laData.Size = new System.Drawing.Size(237, 20);
            // 
            // buQuit
            // 
            this.buQuit.Location = new System.Drawing.Point(3, 107);
            this.buQuit.Name = "buQuit";
            this.buQuit.Size = new System.Drawing.Size(234, 46);
            this.buQuit.TabIndex = 4;
            this.buQuit.Text = "Quit";
            this.buQuit.Click += new System.EventHandler(this.buQuit_Click);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(96F, 96F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Dpi;
            this.AutoScroll = true;
            this.ClientSize = new System.Drawing.Size(240, 268);
            this.Controls.Add(this.buQuit);
            this.Controls.Add(this.laData);
            this.Controls.Add(this.laDebug);
            this.Controls.Add(this.buStop);
            this.Controls.Add(this.buStart);
            this.Menu = this.mainMenu1;
            this.Name = "Form1";
            this.Text = "Form1";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button buStart;
        private System.Windows.Forms.Button buStop;
        private System.Windows.Forms.Label laDebug;
        private System.Windows.Forms.Label laData;
        private System.Windows.Forms.Button buQuit;
        private System.Windows.Forms.MenuItem menuItem1;
        private System.Windows.Forms.MenuItem miStartStop;
    }
}

