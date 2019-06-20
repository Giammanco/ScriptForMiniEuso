#include <iostream>
#include <fstream>
#include <vector>
#include <sstream>
#include <string>
using namespace std;

/******************************
DeadPixelMask is given in Human frendly way
this function transforms the coordinate
taking into account that the Ec units have the following
orientation


0   7     56   0

56  63    63   7


7   63    63   56

0   56    7    0

Also we must take into account that the immage sowed by the viewer

is oriented in board and asic as follow:

B5 B4 B3 B2 B1 B0/ A0
                   A1
                   A2
                   A3
                   A4
                   A5


******************************/


void OrderPixelINV(int &x, int &y, int b, int a){

int x2;
int y2;
//int x0=x0;
//int y0=y0;


if((b==0||b==2 || b==4) && (a==0||a==2 || a==4)){

    x2=x;
    y2=y;
       }

if((b==0 || b==2 || b==4) && (a==1 || a==3 || a==5)){


    x2=y;
    y2=abs(x-7);

        }

if((b==1 || b==3 || b==5) && (a==0 || a==2 || a==4)){

    x2=abs(y-7);
    y2=x;


}

if((b==1 || b==3 || b==5 ) && (a==1 || a==3 || a==5)){

    x2=abs(x-7);
    y2=abs(y-7);

}

    x=x2;
    y=y2;

}




int main( int argc, char *argv[]){

    if (argc<2){

    cout<<"\nUse: DAC_TRANSFORM filename \nFilename is where DAC7 or DAC10 matrix are stored\n"<<endl;
    cout<<"The   original   file   is   interpreted   according   to  the following rules:"<<endl;
    cout<<"DAC number is constant along the line and moves from 0 to 5 from top to bottom."<<endl;
    cout<<"ASIC moves from 0  to  5  from left to right and is constant along the columns."<<endl;
    cout<<"Pixel number in   eahc 8x8   sub matrix   increases   from   left-heigh corner."<<endl;
    cout<<"The transformed matrix are in accord with the dispalyed  immages as  documented\nin DeadPiexelRead.cpp\n"<<endl;

     return 1;
        }

    //convert char *arg[] into string
    stringstream ss;
    ss<<argv[1];
    string file=ss.str();


    cout<<file<<endl;

    //create an input file stream
    ifstream matrix(file,ios::in);
    int number;

    vector<int> snake; //vector to store the entire matrix

    while(matrix>>number){

        snake.push_back(number);
        //cout<<number<<endl;
    }


    if(snake.size()!=2304){
        cout<<"ERROR: file \""<<file<<"\" is out of format.\nCheck number of elements."<<endl;
        return 1;

    }
    matrix.close();

    vector<int> reformed;
    reformed.assign(2304,-10);
    /*pixel is the sequential index number of a pixel inside to  [board, asic] matrix
      x,y are the  x, y indices for a pixel inside to [board, asic] matrix
      X,Y are the coordinate of a pixel inside to the general big matrix
      index is the index of a pixel inside to the general big matrix*/
    int x;
    int y;

    int X;
    int Y;
    unsigned int index , Tindex;
    int a, b, pixel, linea, columna;
    int TX, TY;

    for(b=0;b<6;b++){

        for(a=0;a<6;a++){

            for (pixel=0;pixel<64;pixel++){

                x=pixel/8;
                y=pixel-x*8;
                X=b*8+x;
                Y=a*8+y;
                index=X*48+Y; //index of the pixel in big snake vertor

                //the columns and line are changed.a is the column in the original matrix, column is the colum in the results
                linea=a;
                columna=abs(b-5);

                //if(snake[index]==10){cout<<x<<" "<<y<<endl;}
                OrderPixelINV(x,y,linea, columna);
                TX=linea*8+x;
                TY=columna*8+y;
                Tindex=TX*48+TY; //new index for the trasformed matrix
                //if(snake[index]==10){cout<<"("<<linea<<','<<columna<<") ("<<b<<','<<a<<") "<<pixel<<endl;}
                //if(snake[index]==10){cout<<x<<" "<<y<<endl;}
                reformed[Tindex]=snake[index];
                //cout<<reformed[Tindex]<<" ";

            }


        }


    }


   int el=0;
    for(int bl=0; bl<6; bl++){

        for (int sl=0; sl<8 ;sl++){

            for(int bc=0;bc<6;bc++){

                for(int sc=0; sc<8; sc++){

                    cout<<reformed[el]<<" ";
                    el++;
                }

                   cout<<" ";
            }
            cout<<""<<endl;
        }
        cout<<""<<endl;

    }



//for(unsigned nel=0; nel<2304; nel++){

//cout<<reformed[nel];

//}
}
