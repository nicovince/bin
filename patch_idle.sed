#!/bin/sed -f

s/\+?LP_FIQ//
s/LP_IRQ/SRC_IRQ/
s/LP_WKTMR/SRC_TMR/
s/LP_SDIO/SRC_SDIO/
s/LP_MII_LOGIC/SRC_MII_LOGIC/
s/LP_MII_RX_DV/SRC_MII_RX_DV/
s/LP_USB_RESUME/SRC_USB_RESUME/
s/LP_USB_DISCONNECT/SRC_USB_DISCONNECT/
s/LP_USB_CONNECT/SRC_USB_CONNECT/
s/LP_SDIO_LOGIC/SRC_SDIO_LOGIC/
s/LP_CLIENT_FIQ//
s/LP_CLIENT_IRQ//

s/LP_PHY_CG_EN//
s/LP_HCLK_CG_EN//
s/LP_GLOBAL_CG_EN/CMD_GLOBAL_CG_EN/
s/LP_SLEEP_IDLE_ON_OEN0/CMD_SLEEP_IDLE_ON_OEN_0/
s/LP_SLEEP_IDLE_ON_OEN1/CMD_SLEEP_IDLE_ON_OEN_1/
s/LP_RETENTION_NRESTORE/CMD_RETN_NRESTORE/
s/LP_RSTN//
s/LP_PWR_ON/CMD_PWR_ON/
s/LP_ISOLATION_ON/CMD_ISOLATION_ON/
s/LP_RETENTION_SAVE/CMD_RETN_SAVE/
s/LP_DRIVE_IOS//
s/LP_CAPTURE_IOS//
s/LP_PMU_LDO_SLEEP//
s/LP_PMU_BG_ENABLE//
s/LP_PMU_LDO_VOUTCFG_SEL//
s/LP_POWER_MODE0/CMD_PMODE_0/
s/LP_POWER_MODE1/CMD_PMODE_1/
s/LP_POWER_MODE2/CMD_PMODE_2/
