
#import "ipadkeygen.h"
#define VERSION "0.2 (05-23-2011)"

//-------------------------------------
// check_sum to get register number
//-------------------------------------
void check_sum(char *token)
{
 char serial_number_key_new[32];
 char serial_number_temp;
 int i=0;
 int len=0;
 int flag=0; 
  
 len=strlen(token);
 if (len==12)
 {
   //key word: rainbow
   //key rule: (7.1.4.9)-(3.5.12.5)-(8.11.7.3)-(1.9.10.7)-(11.6.2.12) 
   //Number rule1: TIMOAY
   //Number rule2: QSUWYZXVTR
   //Number rule3: 02468ACEGIKMOPNLJHFDB97531
   strcpy(serial_number_key_new,"");
   serial_number_key_new[0]=token[7-1];
   serial_number_key_new[1]=token[1-1];
   serial_number_key_new[2]=token[4-1];
   serial_number_key_new[3]=token[9-1];
   serial_number_key_new[4]='-';
   serial_number_key_new[5]=token[3-1];
   serial_number_key_new[6]=token[5-1];
   serial_number_key_new[7]=token[12-1];
   serial_number_key_new[8]=token[5-1];
   serial_number_key_new[9]='-';
   serial_number_key_new[10]=token[8-1];
   serial_number_key_new[11]=token[11-1];
   serial_number_key_new[12]=token[7-1];
   serial_number_key_new[13]=token[3-1];
   serial_number_key_new[14]='-';
   serial_number_key_new[15]=token[1-1];
   serial_number_key_new[16]=token[9-1];
   serial_number_key_new[17]=token[10-1];
   serial_number_key_new[18]=token[7-1];
   serial_number_key_new[19]='-';
   serial_number_key_new[20]=token[11-1];
   serial_number_key_new[21]=token[6-1];
   serial_number_key_new[22]=token[2-1];
   serial_number_key_new[23]=token[12-1];
   serial_number_key_new[24]='\0';
   for (i=0;i<24;i++)
       {
       if (serial_number_key_new[i]=='}') {serial_number_temp='T';flag=1;}
       if (serial_number_key_new[i]=='!') {serial_number_temp='I';flag=1;}
       if (serial_number_key_new[i]=='%') {serial_number_temp='M';flag=1;}
       if (serial_number_key_new[i]=='(') {serial_number_temp='O';flag=1;}
       if (serial_number_key_new[i]=='_') {serial_number_temp='A';flag=1;}
       if (serial_number_key_new[i]==')') {serial_number_temp='Y';flag=1;}
       
       if (serial_number_key_new[i]=='0') {serial_number_temp='Q';flag=1;}
       if (serial_number_key_new[i]=='1') {serial_number_temp='S';flag=1;}
       if (serial_number_key_new[i]=='2') {serial_number_temp='U';flag=1;}
       if (serial_number_key_new[i]=='3') {serial_number_temp='W';flag=1;}
       if (serial_number_key_new[i]=='4') {serial_number_temp='Y';flag=1;}
       if (serial_number_key_new[i]=='5') {serial_number_temp='Z';flag=1;}
       if (serial_number_key_new[i]=='6') {serial_number_temp='X';flag=1;}
       if (serial_number_key_new[i]=='7') {serial_number_temp='V';flag=1;}
       if (serial_number_key_new[i]=='8') {serial_number_temp='T';flag=1;}
       if (serial_number_key_new[i]=='9') {serial_number_temp='R';flag=1;}

	   if (serial_number_key_new[i]=='A'||serial_number_key_new[i]=='a') {serial_number_temp='0';flag=1;}
       if (serial_number_key_new[i]=='B'||serial_number_key_new[i]=='b') {serial_number_temp='2';flag=1;}
       if (serial_number_key_new[i]=='C'||serial_number_key_new[i]=='c') {serial_number_temp='4';flag=1;}
       if (serial_number_key_new[i]=='D'||serial_number_key_new[i]=='d') {serial_number_temp='6';flag=1;}
       if (serial_number_key_new[i]=='E'||serial_number_key_new[i]=='e') {serial_number_temp='8';flag=1;}
       if (serial_number_key_new[i]=='F'||serial_number_key_new[i]=='f') {serial_number_temp='A';flag=1;}
       if (serial_number_key_new[i]=='G'||serial_number_key_new[i]=='g') {serial_number_temp='C';flag=1;}
       if (serial_number_key_new[i]=='H'||serial_number_key_new[i]=='h') {serial_number_temp='E';flag=1;}
       if (serial_number_key_new[i]=='I'||serial_number_key_new[i]=='i') {serial_number_temp='G';flag=1;}
       if (serial_number_key_new[i]=='J'||serial_number_key_new[i]=='j') {serial_number_temp='I';flag=1;}
	   if (serial_number_key_new[i]=='K'||serial_number_key_new[i]=='k') {serial_number_temp='K';flag=1;}
       if (serial_number_key_new[i]=='L'||serial_number_key_new[i]=='l') {serial_number_temp='M';flag=1;}
       if (serial_number_key_new[i]=='M'||serial_number_key_new[i]=='m') {serial_number_temp='O';flag=1;}
       if (serial_number_key_new[i]=='N'||serial_number_key_new[i]=='n') {serial_number_temp='P';flag=1;}
       if (serial_number_key_new[i]=='O'||serial_number_key_new[i]=='o') {serial_number_temp='N';flag=1;}
       if (serial_number_key_new[i]=='P'||serial_number_key_new[i]=='p') {serial_number_temp='L';flag=1;}
       if (serial_number_key_new[i]=='Q'||serial_number_key_new[i]=='q') {serial_number_temp='J';flag=1;}
       if (serial_number_key_new[i]=='R'||serial_number_key_new[i]=='r') {serial_number_temp='H';flag=1;}
       if (serial_number_key_new[i]=='S'||serial_number_key_new[i]=='s') {serial_number_temp='F';flag=1;}
       if (serial_number_key_new[i]=='T'||serial_number_key_new[i]=='t') {serial_number_temp='D';flag=1;}
	   if (serial_number_key_new[i]=='U'||serial_number_key_new[i]=='u') {serial_number_temp='B';flag=1;}
       if (serial_number_key_new[i]=='V'||serial_number_key_new[i]=='v') {serial_number_temp='9';flag=1;}
       if (serial_number_key_new[i]=='W'||serial_number_key_new[i]=='w') {serial_number_temp='7';flag=1;}
       if (serial_number_key_new[i]=='X'||serial_number_key_new[i]=='x') {serial_number_temp='5';flag=1;}
       if (serial_number_key_new[i]=='Y'||serial_number_key_new[i]=='y') {serial_number_temp='3';flag=1;}
       if (serial_number_key_new[i]=='Z'||serial_number_key_new[i]=='z') {serial_number_temp='1';flag=1;}
       if (flag==1) 
          {
          serial_number_key_new[i]=serial_number_temp;
          flag=0;
          }
       }
   strcpy(token,serial_number_key_new);
   strcat(token," ");
   }
 else
   strcpy(token,"Serial Number Error!");
}

//-------------------------------------
// fill_sum to fill book number
//-------------------------------------
void fill_sum(char *token)
{
 int len=0;//i=0,j=0,
 //int flag=0; 
  
 len=strlen(token);
 //printf("%c\n",token[len-1]);

 if (token[len-1]=='0')
  {
  switch(len)
      {
      case 0:strcat(token,"ZYXWVUTSRQPO");
             break;
      case 1:strcat(token,"YXWVUTSRQPO");
             break;
	  case 2:strcat(token,"XWVUTSRQPO");
             break;
	  case 3:strcat(token,"WVUTSRQPO");
             break;
	  case 4:strcat(token,"VUTSRQPO");
             break;
	  case 5:strcat(token,"UTSRQPO");
             break;
	  case 6:strcat(token,"TSRQPO");
             break;
	  case 7:strcat(token,"SRQPO");
             break;
	  case 8:strcat(token,"RQPO");
             break;
	  case 9:strcat(token,"QPO");
             break;
	  case 10:strcat(token,"PO");
              break;
	  case 11:strcat(token,"O");
              break;
	  case 12:strcat(token,"");
              break;
	  default:strcpy(token,"Book number too long!"); 
		      break;
	  }  
  }
 if (token[len-1]=='1')
  {
  switch(len)
      {
      case 0:strcat(token,"YXWVUTSRQPOZ");
             break;
      case 1:strcat(token,"XWVUTSRQPOZ");
             break;
	  case 2:strcat(token,"WVUTSRQPOZ");
             break;
	  case 3:strcat(token,"VUTSRQPOZ");
             break;
	  case 4:strcat(token,"UTSRQPOZ");
             break;
	  case 5:strcat(token,"TSRQPOZ");
             break;
	  case 6:strcat(token,"SRQPOZ");
             break;
	  case 7:strcat(token,"RQPOZ");
             break;
	  case 8:strcat(token,"QPOZ");
             break;
	  case 9:strcat(token,"POZ");
             break;
	  case 10:strcat(token,"OZ");
              break;
	  case 11:strcat(token,"Z");
              break;
	  case 12:strcat(token,"");
              break;
	  default:strcpy(token,"Book number too long!"); 
		      break;
	  }
  }
  if (token[len-1]=='2')
  {
  switch(len)
      {
      case 0:strcat(token,"XWVUTSRQPOZY");
             break;
      case 1:strcat(token,"WVUTSRQPOZY");
             break;
	  case 2:strcat(token,"VUTSRQPOZY");
             break;
	  case 3:strcat(token,"UTSRQPOZY");
             break;
	  case 4:strcat(token,"TSRQPOZY");
             break;
	  case 5:strcat(token,"SRQPOZY");
             break;
	  case 6:strcat(token,"RQPOZY");
             break;
	  case 7:strcat(token,"QPOZY");
             break;
	  case 8:strcat(token,"POZY");
             break;
	  case 9:strcat(token,"OZY");
             break;
	  case 10:strcat(token,"ZY");
              break;
	  case 11:strcat(token,"Y");
              break;
	  case 12:strcat(token,"");
              break;
	  default:strcpy(token,"Book number too long!"); 
		      break;
	  }
  }
  if (token[len-1]=='3')
  {
  switch(len)
      {
      case 0:strcat(token,"WVUTSRQPOZYX");
             break;
      case 1:strcat(token,"VUTSRQPOZYX");
             break;
	  case 2:strcat(token,"UTSRQPOZYX");
             break;
	  case 3:strcat(token,"TSRQPOZYX");
             break;
	  case 4:strcat(token,"SRQPOZYX");
             break;
	  case 5:strcat(token,"RQPOZYX");
             break;
	  case 6:strcat(token,"QPOZYX");
             break;
	  case 7:strcat(token,"POZYX");
             break;
	  case 8:strcat(token,"OZYX");
             break;
	  case 9:strcat(token,"ZYX");
             break;
	  case 10:strcat(token,"YX");
              break;
	  case 11:strcat(token,"X");
              break;
	  case 12:strcat(token,"");
              break;
	  default:strcpy(token,"Book number too long!"); 
		      break;
	  }
  }
  if (token[len-1]=='4')
  {
  switch(len)
      {
      case 0:strcat(token,"VUTSRQPOZYXW");
             break;
      case 1:strcat(token,"UTSRQPOZYXW");
             break;
	  case 2:strcat(token,"TSRQPOZYXW");
             break;
	  case 3:strcat(token,"SRQPOZYXW");
             break;
	  case 4:strcat(token,"RQPOZYXW");
             break;
	  case 5:strcat(token,"QPOZYXW");
             break;
	  case 6:strcat(token,"POZYXW");
             break;
	  case 7:strcat(token,"OZYXW");
             break;
	  case 8:strcat(token,"ZYXW");
             break;
	  case 9:strcat(token,"YXW");
             break;
	  case 10:strcat(token,"XW");
              break;
	  case 11:strcat(token,"W");
              break;
	  case 12:strcat(token,"");
              break;
	  default:strcpy(token,"Book number too long!"); 
		      break;
	  }
  }
  if (token[len-1]=='5')
  {
  switch(len)
      {
      case 0:strcat(token,"UTSRQPOZYXWV");
             break;
      case 1:strcat(token,"TSRQPOZYXWV");
             break;
	  case 2:strcat(token,"SRQPOZYXWV");
             break;
	  case 3:strcat(token,"RQPOZYXWV");
             break;
	  case 4:strcat(token,"QPOZYXWV");
             break;
	  case 5:strcat(token,"POZYXWV");
             break;
	  case 6:strcat(token,"OZYXWV");
             break;
	  case 7:strcat(token,"ZYXWV");
             break;
	  case 8:strcat(token,"YXWV");
             break;
	  case 9:strcat(token,"XWV");
             break;
	  case 10:strcat(token,"WV");
              break;
	  case 11:strcat(token,"V");
              break;
	  case 12:strcat(token,"");
              break;
	  default:strcpy(token,"Book number too long!"); 
		      break;
	  }
  }
  if (token[len-1]=='6')
  {
  switch(len)
      {
      case 0:strcat(token,"TSRQPOZYXWVU");
             break;
      case 1:strcat(token,"SRQPOZYXWVU");
             break;
	  case 2:strcat(token,"RQPOZYXWVU");
             break;
	  case 3:strcat(token,"QPOZYXWVU");
             break;
	  case 4:strcat(token,"POZYXWVU");
             break;
	  case 5:strcat(token,"OZYXWVU");
             break;
	  case 6:strcat(token,"ZYXWVU");
             break;
	  case 7:strcat(token,"YXWVU");
             break;
	  case 8:strcat(token,"XWVU");
             break;
	  case 9:strcat(token,"WVU");
             break;
	  case 10:strcat(token,"VU");
              break;
	  case 11:strcat(token,"U");
              break;
	  case 12:strcat(token,"");
              break;
	  default:strcpy(token,"Book number too long!"); 
		      break;
	  }
  }
  if (token[len-1]=='7')
  {
  switch(len)
      {
      case 0:strcat(token,"SRQPOZYXWVUT");
             break;
      case 1:strcat(token,"RQPOZYXWVUT");
             break;
	  case 2:strcat(token,"QPOZYXWVUT");
             break;
	  case 3:strcat(token,"POZYXWVUT");
             break;
	  case 4:strcat(token,"OZYXWVUT");
             break;
	  case 5:strcat(token,"ZYXWVUT");
             break;
	  case 6:strcat(token,"YXWVUT");
             break;
	  case 7:strcat(token,"XWVUT");
             break;
	  case 8:strcat(token,"WVUT");
             break;
	  case 9:strcat(token,"VUT");
             break;
	  case 10:strcat(token,"UT");
              break;
	  case 11:strcat(token,"T");
              break;
	  case 12:strcat(token,"");
              break;
	  default:strcpy(token,"Book number too long!"); 
		      break;
	  }
  }
  if (token[len-1]=='8')
  {
  switch(len)
      {
      case 0:strcat(token,"RQPOZYXWVUTS");
             break;
      case 1:strcat(token,"QPOZYXWVUTS");
             break;
	  case 2:strcat(token,"POZYXWVUTS");
             break;
	  case 3:strcat(token,"OZYXWVUTS");
             break;
	  case 4:strcat(token,"ZYXWVUTS");
             break;
	  case 5:strcat(token,"YXWVUTS");
             break;
	  case 6:strcat(token,"XWVUTS");
             break;
	  case 7:strcat(token,"WVUTS");
             break;
	  case 8:strcat(token,"VUTS");
             break;
	  case 9:strcat(token,"UTS");
             break;
	  case 10:strcat(token,"TS");
              break;
	  case 11:strcat(token,"S");
              break;
	  case 12:strcat(token,"");
              break;
	  default:strcpy(token,"Book number too long!"); 
		      break;
	  }
  }
  if (token[len-1]=='9')
  {
  switch(len)
      {
      case 0:strcat(token,"POZYXWVUTSRQ");
             break;
      case 1:strcat(token,"OZYXWVUTSRQ");
             break;
	  case 2:strcat(token,"ZYXWVUTSRQ");
             break;
	  case 3:strcat(token,"YXWVUTSRQ");
             break;
	  case 4:strcat(token,"XWVUTSRQ");
             break;
	  case 5:strcat(token,"WVUTSRQ");
             break;
	  case 6:strcat(token,"VUTSRQ");
             break;
	  case 7:strcat(token,"UTSRQ");
             break;
	  case 8:strcat(token,"TSRQ");
             break;
	  case 9:strcat(token,"SRQ");
             break;
	  case 10:strcat(token,"RQ");
              break;
	  case 11:strcat(token,"Q");
              break;
	  case 12:strcat(token,"");
              break;
	  default:strcpy(token,"Book number too long!"); 
		      break;
	  }
  }
  if (token[len-1]=='}'||token[len-1]=='!'||token[len-1]=='%'||token[len-1]=='('||token[len-1]=='_'||token[len-1]==')')
  {
  switch(len)
      {
      case 0:strcat(token,"QPOZYXWVUTSR");
             break;
      case 1:strcat(token,"POZYXWVUTSR");
             break;
	  case 2:strcat(token,"OZYXWVUTSR");
             break;
	  case 3:strcat(token,"ZYXWVUTSR");
             break;
	  case 4:strcat(token,"YXWVUTSR");
             break;
	  case 5:strcat(token,"XWVUTSR");
             break;
	  case 6:strcat(token,"WVUTSR");
             break;
	  case 7:strcat(token,"VUTSR");
             break;
	  case 8:strcat(token,"UTSR");
             break;
	  case 9:strcat(token,"TSR");
             break;
	  case 10:strcat(token,"SR");
              break;
	  case 11:strcat(token,"R");
              break;
	  case 12:strcat(token,"");
              break;
	  default:strcpy(token,"Book number too long!"); 
		      break;
	  }
  }

}

