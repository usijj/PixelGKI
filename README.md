### SukiSU KPM(Optional) susfs patched kernel for Pixel (GKI2.0)

### Github Actions
>[!TIP]
>Do it yourself  
>Create a new fork, click on Actions tab then select Buildkernel click Run workflow (kernel customization)  
>When complete, kernel is available for download.   
### Local Script
 >[!TIP]
>If create a new fork, remember to change github username in the link below.
```
git clone https://github.com/fixedcode/PixelGKI.git
```
```
cd PixelGKI
```
```
chmod +x Buildkernel.sh
```
```
./Buildkernel.sh
```

>[!NOTE]
>Backup original boot.img
>  
>Use fastboot or AnyKernel3 method 
>  
>[fastboot]  
>[Using magiskboot patch boot.img manually](https://kernelsu.org/guide/installation.html#using-magiskboot-on-PC)   
>Execute the last step, this image has been changed to kernel. 
>  
>[AnyKernel3]   
>Using [HorizonKernelFlasher](https://github.com/libxzr/HorizonKernelFlasher) or other kernel flasher to flash  


### Credits
[AnyKernel3](https://github.com/osm0sis/AnyKernel3) [KernelSU](https://kernelsu.org/) [SukiSU](https://github.com/SukiSU-Ultra/SukiSU-Ultra) [susfs](https://gitlab.com/simonpunk/susfs4ksu)
