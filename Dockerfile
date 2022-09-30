FROM node:lts-alpine AS build
WORKDIR /app

# 配置alpine国内镜像加速
# RUN sed -i "s@http://dl-cdn.alpinelinux.org/@https://repo.huaweicloud.com/@g" /etc/apk/repositories

# 如果各公司有自己的私有源，可以替换registry地址,如使用官方源注释下一行
RUN npm config set registry https://registry.npm.taobao.org

# 安装开发期依赖
COPY package.json ./package.json
RUN npm install

# 构建项目
COPY . .
RUN npm run build

FROM node:lts-alpine
WORKDIR /app

COPY --from=build /app/dist ./dist
COPY --from=build /app/bootstrap.js ./
COPY --from=build /app/package.json ./

# 安装tzdata,默认的alpine基础镜像不包含时区组件，安装后可通过TZ环境变量配置时区
RUN apk add --no-cache tzdata

# 设置时区为中国东八区，这里的配置可以被docker-compose.yml或docker run时指定的时区覆盖
ENV TZ="Asia/Shanghai"
 
# 安装生产环境依赖   
RUN npm install --production                          

CMD ["npm", "run", "start"]