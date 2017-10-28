clear all;
clc;
%% Specify time
dt = 1; T = 8000;
t=0:dt:T;
%%Specifying the length of the coefficient aa
da=0.001;%increase the length of the interval
aa=0.97;
a=0:da:aa;

%% Initializations
alti=600000; % in meters 
Re = 6371.2e3;
Rc = Re+alti; %  Distance from earth in metres
p=((111e3*Rc)/Re);
G = 6.67428e-11; % Earth gravitational constant
M = 5.972e24; % Earth mass
linvel = sqrt(G*M/Rc); %linear velocity of the satellite
per_err=[0.5;1;1.5;2;2.5;3;3.5;4];% represents the matrix in the   %maximum percentage error.
per_err=per_err.*0.01;
mina=zeros(2,8);
bmodifiedx=zeros(1,length(t));% to store the modified magnetic field
bmodifiedy=zeros(1,length(t));% to store the modified magnetic field
bmodifiedz=zeros(1,length(t));% to store the modified magnetic field
boriginalx=zeros(1,length(t));%to store the original values of the magnetic field  
bfilterx=zeros(1,length(t));%to store the filtered value
boriginaly=zeros(1,length(t));%to store the original values of the magnetic field  
bfiltery=zeros(1,length(t));%to store the filtered value
boriginalz=zeros(1,length(t));%to store the original values of the magnetic field  
bfilterz=zeros(1,length(t));%to store the filtered value
mserrx=zeros(1,length(a));
mserry=zeros(1,length(a));
mserrz=zeros(1,length(a));
mserr=zeros(1,length(a));
%mse_x=zeros(8);
%pq=1:1:8;


%%
  for ik=1:length(t)
    
    lati=(linvel*ik*dt)/p;% as its a latitude changes differently when its in space.
    lat=-89+lati; 
    % setting up the latitude for the law, latitude changes due to the change in the y coordinate of the system.
    long=60+((7.29e-5*ik*dt)*180/3.14);
    %longitude change as the eath is rotating
    % Gives error on 90
     if lat>90
        b=mod(lat,90);
        lat=90-b;
    end
    if lat<-90
        c=mod(lat,-90);
        lat=-90-c; 
    end
     if long>180
        d=mod(long,180);
        long=d-180;

     end
    if long<-180
        l=mod(long,-180);
        long=180+l;
    end
    if lat==90
        lat=89.97;
    end
    if lat==-90
        lat=-89.97;
    end
       
    [mag_field_vector1,hor_intensity,declination,inclination,total_intensity] = wrldmagm(alti,lat,long,decyear(2015,7,4),2015); 
    mag_field_vector=mag_field_vector1*1;
    % as its in the form of nano tesla
    
    
    boriginalx(ik)=mag_field_vector(1);
    boriginaly(ik)=mag_field_vector(2);
    boriginalz(ik)=mag_field_vector(3);
    bf(ik) = sqrt ( dot (mag_field_vector,mag_field_vector) );
    
  end
%   for count=1:1:8
%       mina(2,count)=1;
%       mina(1
%       ,count)=1;
% 
%   end    
    
  %%
 %for ij=1:1:8
ij = 4;
 for pq=1:length(a);

    
     
  for ik=1:length(t)%change it afterwards
     
    x=rand;
    y=rand;%to decide if the randomised no. is -ve or +ve
    if y>0.5
    err= x * per_err(ij);
    else
    err= -x * per_err(ij); 
    end
    bmodifiedx(ik)=(1+err)*boriginalx(ik);
    bmodifiedy(ik)=(1+err)*boriginaly(ik);
    bmodifiedz(ik)=(1+err)*boriginalz(ik);
    if ((ik==1)||(mod(ik,799)==0))
       bfilterx(ik)=a(pq)*bmodifiedx(ik);
       bfiltery(ik)=a(pq)*bmodifiedy(ik);    
       bfilterz(ik)=a(pq)*bmodifiedz(ik);
    else
       bfilterx(ik)=(a(pq)*bfilterx(ik-1))+((1-a(pq))*bmodifiedx(ik));
       bfiltery(ik)=(a(pq)*bfiltery(ik-1))+((1-a(pq))*bmodifiedy(ik));
       bfilterz(ik)=(a(pq)*bfilterz(ik-1))+((1-a(pq))*bmodifiedz(ik));
    end
   
  end
  mserrx(pq)=(mean((boriginalx-bfilterx).^2));
  mserry(pq)=(mean((boriginaly-bfiltery).^2));
  mserrz(pq)=(mean((boriginalz-bfilterz).^2));
%   disp(mserrz(pq));
  mserr(pq)=mserrx(pq)+mserry(pq)+mserrz(pq);
%   disp(mserr(pq));
% if(mserr(pq)<mina(2,ij))
%    mina(2,ij)=mserr(pq);
%    mina(1,ij)=a(pq);
% end   
end
  
  
 % xlim([0,1]);
 % ylim([1,1e-20]);
 plot(a,mserr);
 hold on;
  
% end
