FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base
WORKDIR /app
EXPOSE 80
# EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY ["Api/Api.csproj", "./Api/"]
COPY ["Api.Test/Api.Test.csproj", "./Api.Test/"]
COPY ["Core/Core.csproj", "./Core/"]
RUN dotnet restore "./Api/Api.csproj"
RUN dotnet restore "./Api.Test/Api.Test.csproj"
RUN dotnet restore "./Core/Core.csproj"
COPY "Api/." "./Api/"
COPY "Api.Test/." "./Api.Test/"
COPY "Core/." "./Core/"
RUN dotnet build "./Api/Api.csproj" -c Release -o /app/build
RUN dotnet build "./Api.Test/Api.Test.csproj"
RUN dotnet test "./Api.Test/Api.Test.csproj"

FROM build AS publish
RUN dotnet publish "./Api/Api.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Api.dll"]

# docker build -t weather-app -f Api.Dockerfile .
# docker run -it --rm -p 8080:80 weather-app
