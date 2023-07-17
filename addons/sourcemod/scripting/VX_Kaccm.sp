#include <sourcemod>
#include <cstrike>
#include <multicolors>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0"


public Plugin myinfo = 
{
    name = "[VX - FUN] !kaçcm", 
    author = "SoupSpy!#5006", 
    description = "Oyunculara !kaçcm komutunu sunar. Eğlence amaçlıdır", 
    version = PLUGIN_VERSION, 
    url = "http://vortex.oyunboss.net/"
};


ConVar g_csPrefix;
ConVar g_cPluginDurum;
ConVar g_cVeriDurum;
ConVar g_ciMinCM;
ConVar g_ciMaxCM;
ConVar g_ciCoolDownSEC;

public void OnPluginStart()
{
    
    g_csPrefix = CreateConVar("sm_vxkaccm_prefix", "{red}[VortéX {yellow}FUN{red}]", "");
    g_cPluginDurum = CreateConVar("sm_vxkaccm_enable", "1", "0->Kapatır,1->Açar", _, true, 0.0, true, 1.0);
    g_cVeriDurum = CreateConVar("sm_vxkaccm_hatirla", "1", "0->Kapatır,1->Açar | Kişi oyunda çıkana kadar ilk çıkardığı uzunluğu sistem veride tutar.", _, true, 0.0, true, 1.0);
    g_ciMinCM = CreateConVar("sm_vxkaccm_min", "3", "Minimum uzunluk", _, true, 1.0);
    g_ciMaxCM = CreateConVar("sm_vxkaccm_max", "31", "Maximum uzunluk");
    g_ciCoolDownSEC = CreateConVar("sm_vxkaccm_cooldown", "15", "0->Kapatır");
    
    AddCommandListener(Listener_Say, "say");
    AddCommandListener(Listener_Say, "say_team");
    
    LoadTranslations("vx_kaccm.phrases");
}

int g_iPlayerCM[MAXPLAYERS + 1] = { 0, ... };
bool g_bPlayerCooldown[MAXPLAYERS + 1] = { false, ... };

public void OnClientPutInServer(int client)
{
    g_iPlayerCM[client] = 0;
    g_bPlayerCooldown[client] = false;
}

public Action Listener_Say(int client, const char[] command, int argc)
{
    char sMessage[7];
    GetCmdArg(1, sMessage, sizeof(sMessage));
    
    StripQuotes(sMessage);
    TrimString(sMessage);
    
    if (strcmp(sMessage, "!kaccm", false) == 0 || strcmp(sMessage, "!kaçcm", false) == 0 || strcmp(sMessage, "/kaccm", false) == 0 || strcmp(sMessage, "/kaçcm", false) == 0)
    {
        if ( !GetConVarBool(g_cPluginDurum) )
            return Plugin_Handled;
            
        char sPrefix[66]; GetConVarString(g_csPrefix, sPrefix, 66);
        
        if (g_bPlayerCooldown[client])
        {
            CPrintToChat(client, "%s {red}%t", sPrefix, "CoolDown");
            return Plugin_Handled;
        }
        
        int iCM;
        if (GetConVarBool(g_cVeriDurum) && g_iPlayerCM[client]>0)
            iCM = g_iPlayerCM[client];
        else iCM = GetRandomInt(GetConVarInt(g_ciMinCM), GetConVarInt(g_ciMaxCM));
        
        char sName[32]; GetClientName(client, sName, 32);
        
        if (GetConVarBool(g_cVeriDurum) && g_iPlayerCM[client]==0)
            g_iPlayerCM[client] = iCM;
        
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientValid(i))
            {
                CPrintToChat(i, "%s {default}%t", sPrefix, "Kaccm", sName, iCM);
            }
        }
        
        int iCoolDownSec = GetConVarInt(g_ciCoolDownSEC);
        if (iCoolDownSec > 0)
        {
            g_bPlayerCooldown[client] = true;
            CreateTimer(iCoolDownSec * 1.0, Timer_Cooldown, client);
        }
    }
    
    return Plugin_Continue;
    
}

public Action Timer_Cooldown(Handle timer, any client)
{
    g_bPlayerCooldown[client] = false;
}

stock bool IsClientValid(int client)
{
    if (IsClientInGame(client) && IsClientConnected(client) && 0 < client <= MaxClients && !IsFakeClient(client))
        return true;
    return false;
}
