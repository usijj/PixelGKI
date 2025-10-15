### SukiSU susfs KPM(Optional) patched kernel for Pixel (Tensor)

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
### How to flash
>[!NOTE]
>Backup stock boot.img
>  
>Use fastboot or AnyKernel3 method 
>  
>[fastboot]  
>Using [magiskboot](https://kernelsu.org/guide/installation.html#using-magiskboot-on-PC)  patch stock boot.img manually   
>Execute the last step (this image has been changed to kernel)  
>  
>[AnyKernel3] (requires root)   
>Using [HorizonKernelFlasher](https://github.com/libxzr/HorizonKernelFlasher)


### Credits
[AnyKernel3](https://github.com/osm0sis/AnyKernel3) [KernelSU](https://kernelsu.org/) [SukiSU](https://sukisu.org/) [susfs](https://gitlab.com/simonpunk/susfs4ksu)
