/*
  © (ɔ) QuoInsight
*/
int _CRT_glob = 0; // turn off globbing to avoid command line wildcard expansion [Windows only]

#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

int trimc(char c) { return (c==' '||c=='\t'||c=='\r'||c=='\n'); }
char* ltrim(char* s) { while (s!=NULL && s[0]!='\0' && trimc(*s)) s++;  return s; }
char* rtrim(char* s) { if (s==NULL || s[0]=='\0') return NULL; for (int i=strlen(s)-1; i>=0; i--) if (trimc(s[i])) s[i]='\0'; else break;  return s; }
char* trim(char* s) { return ltrim(rtrim(s)); }

time_t roundMinutes(time_t t, int m)
{
  const int intInterval = 60 * m;
  /*
    double round(double x) {
      return (floor (x+0.5)); // or return (ceil (x-0.5));
    }
  */
  return (int)((double)t/intInterval + 0.5) * intInterval;
}

int matchCronParam(char *cfgParam, int actVal) {
  char c, *s, *s1;
  int i, j;

  if (strlen(cfgParam)==0) return 1; /*true*/
  c = (int)*cfgParam; if (c=='*'||c=='a'||c=='x') return 1; /*true*/

  s = strtok(cfgParam, ",");
  do {
    /*printf("%s\t",s);/**/
    i = strtol(s, (char **)NULL, 10); /*atoi strtol*/
    if ( (s1=strstr(s, "-")) != NULL ) {
      j = strtol(++s1, (char **)NULL, 10);
      /*printf("[%d] [%d]\n", i, j);/**/
      if (actVal>=i && actVal<=j) return 1; /*true*/
    } else {
      /*printf("[%d]\n", i);/**/
      if (actVal==i) return 1; /*true*/
    }
  } while ( (s=strtok(NULL, ",")) != NULL );

  return 0; /*false*/
}

int main(int argc, char *argv[]) 
{
  struct tm *tm;
  time_t current = time(0);

  int i=0, l=0;
  char *progname;

  if (argc!=2 && argc!=6) {
    progname = argv[0];  l = strlen(progname);
    progname = progname + l; /*point to end of string*/
    for (i=0; i<l; i++) {
      if (*progname=='\\' || *progname=='/' ) {
        progname++;  break;
      }
      progname--; /*moving backwards*/
      *progname = toupper((int)*progname);
    }
    printf(" usage: %s mi hr dd mm wd\n", progname);
    printf("        %s infile\n", progname);
    puts("");
    printf("   mi \t minute [*, 0 - 59]\n");
    printf("   hr \t hour [*, 0 - 23]\n");
    printf("   dd \t day of month [*, 1 - 31]\n");
    printf("   mm \t month [*, 1 - 12]\n");
    printf("   wd \t day of week [*, 0 - 6] [Sunday=0]\n");
    puts("");
    printf(" examples: \n");
    puts("");
    printf("   %s 0 0 * * *\n", progname);
    printf("     runs daily at 12:00am\n");
    printf("   %s 0,15,30,45 * * * 1-5\n", progname);
    printf("     runs every 15 minutes, on weekdays only\n");
    puts("");
    return 1;
  }

  current = roundMinutes(current, 5);
  tm = localtime(&current);
  printf("%s", ctime(&current));

  if (argc == 2) {

    FILE *f = NULL;
    if (strcmp(argv[1],"-")==0) {
      f = stdin;
    } else {
      f = fopen(argv[1], "r");
    }
    if (f==NULL) {
      printf("Failed on fopen [%s]\n", argv[1]);
      return 1;
    }

    char* line;  int maxlen=256;  int linecount=0;
    line = (char*)malloc(maxlen);
    char l_argv[6][maxlen];  int l_argc=0;

    while (fgets(line, maxlen, f)) {
      ++linecount;  line=trim(line);
      sprintf(l_argv[0], "Line#%d",linecount);
      printf("[%s]\n", line);
      if (line!=NULL && line[0]!='#') {
        l_argc = 1;
        char * token = strtok(line, " ");
        // loop through the string to extract all other tokens
        while( token != NULL ) {
          if (l_argc==6) {
            printf("warning: skip the rest of [%s] after [%s], ignore [%s ...] \n", l_argv[0], l_argv[5], token);
            break;
          }
          // printf( "[#%d = %s\n", l_argc, token); //printing each token
          strcpy(l_argv[l_argc++], token);
          token = strtok(NULL, " ");
        }
        if (l_argc!=6) {
          printf("warning: skip this line#%d\n", linecount);
        }

        if ( matchCronParam(l_argv[1], tm->tm_min)
          && matchCronParam(l_argv[2], tm->tm_hour)
          && matchCronParam(l_argv[3], tm->tm_mday)
          && matchCronParam(l_argv[4], tm->tm_mon+1)
          && matchCronParam(l_argv[5], tm->tm_wday)
        ) {
          printf("OK. Line#%d\n", linecount);
          return 0;
        }

      }
    }
    fclose(f);

    printf("NO MATCH\n");
    return 1;

  } else if (argc == 6) {

  /*
    printf("tm_sec   seconds after the minute (from 0) = %d\n", tm->tm_sec);
    printf("tm_min   minutes after the hour (from 0) = %d\n", tm->tm_min);
    printf("tm_hour  hour of the day (from 0) = %d\n", tm->tm_hour);
    printf("tm_mday  day of the month (from 1) = %d\n", tm->tm_mday);
    printf("tm_mon   month of the year (from 0) = %d\n", tm->tm_mon);
    printf("tm_year  years since 1900 (from 0) = %d\n", tm->tm_year);
    printf("tm_wday  days since Sunday (from 0) = %d\n", tm->tm_wday);
    printf("tm_yday  day of the year (from 0) = %d\n", tm->tm_yday);
    printf("tm_isdst Daylight Saving Time flag = %d\n", tm->tm_isdst);
  */
    if (! matchCronParam(argv[1], tm->tm_min)   ) return 1;
    if (! matchCronParam(argv[2], tm->tm_hour)  ) return 1;
    if (! matchCronParam(argv[3], tm->tm_mday)  ) return 1;
    if (! matchCronParam(argv[4], tm->tm_mon+1) ) return 1;
    if (! matchCronParam(argv[5], tm->tm_wday)  ) return 1;

    printf("OK\n");
    return 0;
  }

  return 0;
}
