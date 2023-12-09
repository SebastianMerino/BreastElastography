function Vel = loupas_ur(IQData)
    IQData_u = IQData;
    NImages=size(IQData_u,3);
    FrameStep=1;
    Autocorfull(:,:,(FrameStep+1):NImages) = IQData_u(:,:,1:(NImages-FrameStep)).* conj(IQData_u(:,:,(1+FrameStep):NImages));
    Autocor = zeros(size(Autocorfull));
    Autocor(2:end-2,:,2:NImages) = (Autocorfull(4:end,:,2:NImages)+ Autocorfull(3:end-1,:,2:NImages)+ Autocorfull(2:end-2,:,2:NImages)+Autocorfull(1:end-3,:,2:NImages))/4;
    Vel = double(squeeze(-angle(Autocor)));
    Vel = Vel(:,:,2:end);
end