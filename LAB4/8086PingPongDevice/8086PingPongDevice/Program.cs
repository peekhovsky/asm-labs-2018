using System;
using System.Collections.Generic;

using System.Text;


namespace _8086PingPongDevice
{
    class Program
    {
        static void Main(string[] args)
        {
            //Emu8086.IO.WRITE_IO_WORD(123,9994);
            //Emu8086.IO.WRITE_IO_BYTE(121, 1);
            int i = 0;
            int frst = Emu8086.IO.READ_IO_WORD(123), scnd;
            while (true)
            {
                //scnd =Emu8086.IO.READ_IO_WORD(123);
                //if (frst != scnd)
                //{
                //    scnd = Emu8086.IO.READ_IO_WORD(123);
                //    int x, y;
                //    Console.WriteLine((x = (scnd >> 8 & 255)) + " - " + (y = (scnd & 255)));
                //}
                if (Emu8086.IO.READ_IO_BYTE(121) == 1)
                {
                    System.Threading.Thread.Sleep(5000);
                    Emu8086.IO.WRITE_IO_WORD(123,Convert.ToInt16((9985 + (int)(new Random().NextDouble() * 20))));
                    Emu8086.IO.WRITE_IO_BYTE(121, 0);
                }
                //i++;
                //i %= 30;
                //x = i;
                //x=x<<8;
                //x=x|y;
                //System.Threading.Thread.Sleep(3000);
                //Emu8086.IO.WRITE_IO_WORD(123,Convert.ToInt16(x));
            }
        }
    }
}
