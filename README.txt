<template>
  <div class="demo" ref="demo">
    <!-- 注意 这里我设置了静音  muted -->
    <video
      ref="video"
      autoplay
      muted
      playsinline
      webkit-playsinline
      style="width:0;height:0"
    ></video>
  </div>
</template>

<script>
  // import Vconsole from 'vconsole'
  
import * as THREE from 'three'
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js'
import * as d3 from 'd3'
// webrtc 资料
// https://blog.csdn.net/yangzhenping/article/details/78895208?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522164817406916782246448540%2522%252C%2522scm%2522%253A%252220140713.130102334.pc%255Fall.%2522%257D&request_id=164817406916782246448540&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~first_rank_ecpm_v1~rank_v31_ecpm-2-78895208.142^v3^pc_search_result_control_group,143^v4^register&utm_term=getUserMedia+%E7%94%BB%E8%B4%A8%E4%BD%8E
export default {
  name: 'demo',
  data() {
    return {
      scene: null,
      camera: null,
      renderer: null,
      moduleObj: null,
      canvasblobs: [],
      mediaRecorder: null,
      canvasStream: null,
      // 双指
      // 第一个手指数据
      oneData: [],
      // 第二个手指数据
      twoData: [],
      long: 0
    }
  },
  async mounted() {
    // return
    // 从这里保存这里的this  为了接下里的函数使用
    const self = this
    const box = this.$refs.demo
    box.style.height = window.innerHeight + 'px'
    // 场景
    const scene = new THREE.Scene()

    // 摄像机
    const camera = new THREE.PerspectiveCamera(
      30,
      box.clientWidth / box.clientHeight, //使摄像机和屏幕比一样
      1,
      1000
    )
    // 渲染器                         这个配置 是为了开启一个什么缓冲区   不开这个 无法拍照
    const renderer = new THREE.WebGLRenderer({ preserveDrawingBuffer: true })
    // 设置渲染器大小
    renderer.setSize(box.clientWidth, box.clientHeight)
    /* 
    包含颜色信息（.map、.emissiveMap 和 .specularMap）的纹理在 glTF 中始终使用 sRGB 颜色空间，
    而顶点颜色和材质属性（.color、.emissive、.specular）使用线性颜色空间。在典型的渲染工作流程中，
    渲染器将纹理转换为线性色彩空间，进行光照计算，然后将最终输出转换回 sRGB 并显示在屏幕上。
    除非您需要在线性色彩空间中进行后期处理，否则在使用 glTF 时始终按如下方式配置 WebGLRenderer ：
    renderer.outputEncoding = THREE.sRGBEncoding;
    */
    // renderer.setClearColor('#fff', 1.0)
    // 向赫兹中加入渲染器
    box.appendChild(renderer.domElement)
    renderer.outputEncoding = THREE.sRGBEncoding
    // 摄像头录制      这个函数有很多版本 用来兼容各个浏览器的，当然当前这个就是兼容性最好的，可以去网上搜一下用来专门兼容其他浏览器的，然后进行判断和选择
    // console.log(navigator.mediaDevices.getUserMedia)
    // navigator.getUserMedia =
    //   navigator.mediaDevices.getUserMedia ||
    //   navigator.webkitGetUserMedia ||
    //   navigator.mozGetUserMedia
    // const mediaStream = await navigator.mediaDevices.getUserMedia({
    //   // video属性设置 开摄像头的
    //   video: {
    //     width: { min: box.clientWidth },
    //     height: { min: box.clientHeight }
    //     // 下面这个是开后置摄像头的   根据需要打开
    //     // facingMode: { exact: "environment" },
    //   },
    //   // audio属性设置   开麦克风的
    //   audio: {
    //     // 是否尝试去除音频信号中的背景噪声
    //     noiseSuppression: true,
    //     // 回声取消
    //     echoCancellation: true
    //   }
    // })
    /* 
    权限
      在一个可安装的app（如Firefox OS app）中使用 getUserMedia() ，你需要在声明文件中指定以下的权限：

      "permissions": {
        "audio-capture": {
          "description": "Required to capture audio using getUserMedia()"
        },
        "video-capture": {
          "description": "Required to capture video using getUserMedia()"
        }
      } 
*/

    // const video = this.$refs.video
    // // 成功返回promise对象，接收一个mediaStream参数与video标签进行对接
    // video.srcObject = mediaStream
    // video.play()

    // 加入作为背景的面  这里干的事情，就是用一个平面模型  把模型的材质变成了录制的视频
    // const texture = new THREE.VideoTexture(video)
    // texture.minFilter = THREE.LinearFilter
    // texture.magFilter = THREE.LinearFilter
    // texture.format = THREE.RGBFormat

    const bgw = 30
    //页面 图像出现压扁 拉长情况  是在这个地方去配置的，第一个参数是宽度的截取  第二个参数是高度的截取
    // 苹果手机出现的拉长  在这里加个if判断  是苹果的话，算法就改变一下  把第一个参数 变得更多一些 就正常了
    const geometry = new THREE.PlaneGeometry(
      bgw,
      bgw / (box.clientWidth / box.clientHeight)
    )
    // const material = new THREE.MeshBasicMaterial({
    //   map: texture,
    //   side: THREE.DoubleSide
    // })
    // const cube = new THREE.Mesh(geometry, material)
    camera.position.z = 100 //参数
    // 以下这行代码 代表着是否横向翻转镜像 打开，就像照镜子一样了
    // cube.rotation.y += 3.1415
    //增加环境光
    var light = new THREE.AmbientLight( 0xffffff,0.3); 
    scene.add( light );
    var directionalLight = new THREE.DirectionalLight( 0xffffff, 2.5 );
    scene.add( directionalLight );

    // scene.add(cube)
    // 加载3D
    this.fnLoad3D()
    // cube.rotation.y = 1.6
    function animate() {
      // 60赫兹刷新率的执行本函数， 比定时器更流畅更适合屏幕
      requestAnimationFrame(animate)
      // 如何引入了模型 就把模型里的内容 进行改变
      // 以下这两行 打开后 可以去看整体是咋样的 搞不明白物体位置时候 就尝试打开
      if(self.moduleObj){
        self.moduleObj.rotation.y += 0.01
        self.moduleObj.rotation.x += 0.01
      }
      
      // /渲染
      renderer.render(scene, camera)
    }
    animate()
    this.scene = scene
    this.camera = camera
    this.renderer = renderer
    // this.initStream = mediaStream
    // // 初始位置
    // self.moduleObj.scene.rotation.y = 0
    // self.moduleObj.scene.rotation.x = 0
    // 缩放 去设置双指时候执行  333行
    this.fnDo()
  },
  methods: {
    // 加载3D模型的函数
    fnLoad3D() {
      // 注意这个loader 是专门引入.glb格式的模型的 需要的话  请在three官网找需要的loader  而引入地址是一样的
      const loader = new GLTFLoader()
      // 这块就是引入模型地址的方式  可以使用动态引入
      loader.load(
        'http://qiyuan.mobi/3d/20220330/lingpai/models/lingpai.gltf',
        model => {
          // 把模型的东西 放入这个盒子里
          this.scene.add(model.scene)
          this.moduleObj = model
          this.moduleObj.scene.rotation.y = 180
          
          // !注意， 因为我不知道导入的模型都会有啥，我也没完整学过模型的东西 所以 这里导入复杂的后 怎么处理模型 均需要您在three里面找到对应的方法
          //  可以通过if（...）    这样来判断某些东西存在 就引入 不存在就不引入的方式进行  关于引入模型包含的那些字段 您学模型的肯定知道都啥意思
          // 还有就是 我的模型 导出时候 选择了  !! 自发光 !!  如果您那边出现了看不见模型 也没有报错信息  就可能是灯光方面的问题  也或者加个全局日光灯 或者在摄像机方向对着加个光
          // http://www.yanhuangxueyuan.com/threejs/docs/#api/zh/lights/AmbientLight  全局环境光
          // 当然 也可能是外包的制作模型的那些人导出没有带上所有东西的问题
          // s.prototype.$vConsole =new  Vconsole()
        },
        undefined,
        function(error) {
          console.log(error)
        }
      )
    },
    // 为了改变每个物体按照自己的原点旋转
    changePivot(obj, scene) {
      let center = new THREE.Vector3()
      obj.geometry.computeBoundingBox()
      obj.geometry.boundingBox.getCenter(center)
      let wrapper = new THREE.Object3D()
      wrapper.position.set(center.x, center.y, center.z)
      obj.position.set(-center.x, -center.y, -center.z)
      // 注意这个鬼东西，会删了原数组中的数据，导致循环不再正确进行
      wrapper.add(obj)
      scene.add(wrapper)
      return wrapper
    },
    // 开始录制canvas
    async fnPlayCanvas() {
      let mimeType = ''
      // 这里判断各种格式 浏览器是否支持 不同格式清晰度也不一样
      // 关于各个类型 清晰度和支持情况  https://developer.mozilla.org/en-US/docs/Web/Media/Formats/WebRTC_codecs
      var types = [
        'video/webm',
        'video/mp4',
        'video/avc',
        'video/ogg',
        'video/webm\;codecs=vp8',
        'video/webm\;codecs=daala',
        'video/webm\;codecs=h264',
        'audio/webm\;codecs=opus',
        'video/mpeg'
      ]

      for (var i in types) {
        if (MediaRecorder.isTypeSupported(types[i])) {
          mimeType = types[i]
          break
        }
      }
      if (mimeType === '') {
        alert('当前浏览器版本过低，请下载新版浏览器')
      }
      //防止重复点击
      if (this.canvasblobs.length > 0) {
        this.canvasblobs = []
      }

      this.$refs.video.play()
      // 录制屏幕
      const canvas = document.querySelector('.demo canvas')
      const Stream = canvas.captureStream()
      // 保存这个canvas流 用于截取拍照
      this.canvasStream = Stream
      // 合并音轨与视频轨道
      const newStream = new MediaStream([
        // 获取视频轨道
        Stream.getVideoTracks()[0],
        // 获取音轨  注意这个音轨，我并未开启音乐播放器 如果需要添加进去多个音轨,或者其他音轨 那后面的0可能就需要改掉，
        // 如果想加入所有音轨 ...this.initStream.getAudioTracks()   用这个方法  三点运算符
        this.initStream.getAudioTracks()[0]
      ])
      let mediaRecorder = new MediaRecorder(newStream, {
        // 这个地方的webm也能设置不同的清晰度
        mimeType,
        ignoreMutedMedia: true,
        //   // 音质
        audioBitsPerSecond: 128000,
        // 画质  可以调高
        videoBitsPerSecond: 2500000
      })
      mediaRecorder.ondataavailable = e => {
        // 保存canvas流数据
        this.canvasblobs.push(e.data)
      }
      mediaRecorder.start(60) //60毫秒记录一次
      this.mediaRecorder = mediaRecorder
    },
    // 保存canvas数据

    fnDownloadCanvas() {
      this.mediaRecorder.stop()
      //  webm是一种浏览器比较通用的视频格式
      //  https://www.npmjs.com/package/webm-to-mp4  这个是一个webm转MP4的js库 可以让后端整个连接 用nodejs加这个库来转换一下
      // 如果是其他的语言  直接搜索 webm转MP4  就能找到   这个是java的 https://www.cnblogs.com/zhwl/p/3645593.html
      // 注意  !!!!!!!!! 苹果的safari就支持MP4
      const ua = navigator.userAgent
      // console.log(navigator.userAgent)
      const isSafari = /(?:Safari)/.test(ua)
      const isAndroid = /(?:Android)/.test(ua)
      let strEnd = 'webm'
      if (isSafari && !isAndroid) {
        strEnd = 'mp4'
      }
      let blob = new Blob(this.canvasblobs, { type: `video/${strEnd}` })
      let url = URL.createObjectURL(blob)
      // console.log(url)
      let a = document.createElement('a')
      a.href = url
      a.style.display = 'none'
      a.download = `record.${strEnd}`
      a.click()
    },
    // 拍照
    fnTakeImg() {
      this.renderer.domElement.toBlob(
        function(blob) {
          let dlLink = document.createElement('a')
          dlLink.download = 'newImg'
          dlLink.style.display = 'none'
          // 字符内容转变成blob地址
          dlLink.href = URL.createObjectURL(blob)
          // 触发点击
          dlLink.click()
        },
        'image/png',
        1
      )
    },
    // 移动模式
    fnMove() {
      const self = this
      d3.select('.demo canvas').call(
        d3.drag().on('drag', function() {
          // 这里其实就是每隔一段时间计算手指位移量
          const d = d3.event
          const cx = d.dx
          const cy = d.dy

          // 上面把每一段时间的位移量 进行一个缩小 改变模型内部的position属性就可以位移了
          self.moduleObj.scene.position.y -= cy / 14
          self.moduleObj.scene.position.x += cx / 14
          //  这个z轴的   就是离摄像机的距离 也就实现了深度
          //  self.moduleObj.scene.position.z
        })
      )
    },
    // 旋转模式
    fnRotate() {
      const self = this
      d3.select('.demo').call(
        d3.drag().on('drag', function() {
          // 这里其实就是每隔一段时间计算手指位移量
          const d = d3.event
          if (d.active !== 1) {
            const cx = d.dx
            const cy = d.dy
            self.moduleObj.scene.rotation.y -= cx / 14
            self.moduleObj.scene.rotation.x += cy / 14
          }

          // 上面把每一段时间的位移量 进行一个缩小 改变模型内部的rotation属性就可以位移了
          // 这里使用时候 注意我跟上面的位移相比  cx 与 cy是反着用的 因为这样更符合操作习惯

          //  这个z轴的   但是对于渲染 两个轴向也够了
          //  self.moduleObj.scene.rotation.z
        })
      )
    },
    // 缩放
    fnDo() {
      const self = this
      d3.select('.demo canvas').call(
        d3.drag().on('drag', function() {
          const d = d3.event
          // 旋转
          if (d.active == 1) {
            const cx = d.dx
            const cy = d.dy
            self.moduleObj.scene.rotation.y -= cx / 14
            self.moduleObj.scene.rotation.x += cy / 14
          }
          // 缩放
          if (d.active == 2) {
      
            // 两个手指移动了的距离
            if (d.identifier === 0) {
              // 初始数据不计算
              if (self.oneData.length === 0) {
                self.oneData = [d.x, d.y]
                self.long = Math.sqrt(
                  (self.oneData[0] - self.twoData[0]) ** 2 +
                    (self.oneData[1] - self.twoData[1]) ** 2
                )
                return
              }
              self.oneData = [d.x, d.y]
            }
            if (d.identifier === 1) {
              if (self.twoData.length === 0) {
                self.twoData = [d.x, d.y]
                self.long = Math.sqrt(
                  (self.oneData[0] - self.twoData[0]) ** 2 +
                    (self.oneData[1] - self.twoData[1]) ** 2
                )
                return
              }
              self.twoData = [d.x, d.y]
            }
            const long = Math.sqrt(
              (self.oneData[0] - self.twoData[0]) ** 2 +
                (self.oneData[1] - self.twoData[1]) ** 2
            )
            let num = long - self.long
            self.long = long
           try {
             
            self.moduleObj.scene.scale.y += num/20       //调整这里数字来调整缩小放大的速度
            self.moduleObj.scene.scale.x += num/20
            self.moduleObj.scene.scale.z += num/20
           } catch (error) {
            //  alert(error)
           }
          }
        })
      )
    }
  }
}
</script>
<style>
* {
  padding: 0;
  margin: 0;
}
</style>
<style scoped>
.demo {
  position: relative;
  display: flex;
  flex-direction: column;
  width: 100vw;
  overflow: hidden;
}
.btns {
  width: 15vw;
  height: 15vw;
  font-size: 16px;
  border-radius: 50%;
  border: 0;
  background: #ffffff00;
}
.btns:active {
  background: #ffffff00;
}
.btnsBox {
  position: fixed;
  width: 100vw;
  bottom: 0;
  left: 0;
}
</style>
