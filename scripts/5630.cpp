#include <windows.h>
#include <stdio.h>

typedef LONG NTSTATUS;

#define SystemTimeInformation 3
#define NT_SUCCESS(Status) ((NTSTATUS)(Status) >= 0)

typedef struct _SYSTEM_TIMEOFDAY_INFORMATION {
    LARGE_INTEGER BootTime;
    LARGE_INTEGER CurrentTime;
    LARGE_INTEGER TimeZoneBias;
    ULONG         TimeZoneId;
    ULONG         Reserved;
    ULONGLONG     BootTimeBias;
    ULONGLONG     SleepTimeBias;
} SYSTEM_TIMEOFDAY_INFORMATION, *PSYSTEM_TIMEOFDAY_INFORMATION;

NTSTATUS (__stdcall *NtQuerySystemInformation)(
    UINT   SystemInformationClass,
    PVOID  SystemInformation,
    ULONG  SystemInformationLength,
    PULONG ReturnLength
);

BOOLEAN (__stdcall *RtlTimeToSecondsSince1970)(
    PLARGE_INTEGER Time,
    PULONG         ElapsedSeconds
);

int main(void) {
  SYSTEM_TIMEOFDAY_INFORMATION sti;
  FILETIME now, cur;
  ULONG    sec1, sec2, delta, t_d, t_h, t_m, t_s, h;
  
  if (!(NtQuerySystemInformation = (void *)GetProcAddress(
      GetModuleHandle("ntdll.dll"), "NtQuerySystemInformation"
  ))) {
    printf("Could not find NtQuerySystemInformation entry point.\n");
    exit(1);
  }
  
  if (!(RtlTimeToSecondsSince1970 = (void *)GetProcAddress(
      GetModuleHandle("ntdll.dll"), "RtlTimeToSecondsSince1970"
  ))) {
    printf("Could not find RtlTimeToSecondsSince1970 entry point.\n");
    exit(1);
  }
  
  if (NT_SUCCESS(NtQuerySystemInformation(SystemTimeInformation, &sti, sizeof(sti), 0))) {
    cur = *(FILETIME *) &sti.BootTime;
    
    GetSystemTimeAsFileTime(&now);
    if (!RtlTimeToSecondsSince1970((PLARGE_INTEGER)&now, &sec1)) return;
    if (!RtlTimeToSecondsSince1970((PLARGE_INTEGER)&cur, &sec2)) return;
    
    delta = sec1 - sec2;
    t_d = delta / 86400;
    t_h = (h = delta / 3600) >= 24 ? h % 24 : h;
    t_m = (delta % 3600) / 60;
    t_s = delta % 60;
    
    printf("uptime v1.0 - System uptime\n");
    printf("Copyright (C) 2014 greg zakharov\n\n");
    printf("%.2d:%.2d:%.2d up %d day%s", t_h, t_m, t_s, t_d,  t_d > 1 ? "s" : "");
  }
  
  return 0;
}
