#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["k8s.net/k8s.net.csproj", "k8s.net/"]
RUN dotnet restore "k8s.net/k8s.net.csproj"
COPY . .
WORKDIR "/src/k8s.net"
RUN dotnet build "k8s.net.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "k8s.net.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "k8s.net.dll"]