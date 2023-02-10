//
//  MetalView.m
//  ZoomVideoSDKSample
//
//  Created by Zoom Video Communications on 2019/1/29.
//  Copyright © 2019 Zoom Video Communications. All rights reserved.
//

#import "MetalView.h"
@import MetalKit;
@import GLKit;

#define kEmojiTag           10002
#define kBackgroudTag       10003

#import "LYShaderTypes.h"
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>

API_AVAILABLE(ios(9.0))
@interface MetalView () <MTKViewDelegate>

// view
@property (nonatomic, strong) MTKView *mtkView;

@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;

// data
@property (nonatomic, assign) vector_uint2 viewportSize;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLTexture> textureY;
@property (nonatomic, strong) id<MTLTexture> textureUV;
@property (nonatomic, strong) id<MTLBuffer> vertices;
@property (nonatomic, strong) id<MTLBuffer> convertMatrix;
@property (nonatomic, assign) NSUInteger numVertices;
@property (nonatomic, assign) CVPixelBufferRef pixelBuffer;

@property (nonatomic, strong) dispatch_semaphore_t inflight_semaphore;

@end

@implementation MetalView

- (void)dealloc
{
    self.textureY = NULL;
    self.textureUV = NULL;
    self.pixelBuffer = NULL;
    self.inflight_semaphore = NULL;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

static const NSInteger kMaxInflightBuffers = 1;
- (void)commonInit {
    self.backgroundColor = [UIColor blackColor];
    
    self.inflight_semaphore = dispatch_semaphore_create(kMaxInflightBuffers);
    self.mtkView = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.mtkView.device = MTLCreateSystemDefaultDevice();
    [self addSubview:self.mtkView];
    self.mtkView.delegate = self;
    self.viewportSize = (vector_uint2){self.mtkView.drawableSize.width, self.mtkView.drawableSize.height};
    
    CVMetalTextureCacheCreate(NULL, NULL, self.mtkView.device, NULL, &_textureCache);

    [self setupPipeline];
    [self setupMatrix];
    
    self.mtkView.paused = YES;
    self.mtkView.enableSetNeedsDisplay = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.mtkView.frame = self.bounds;
    self.viewportSize = (vector_uint2){self.mtkView.drawableSize.width, self.mtkView.drawableSize.height};
    
    for (UIView *subView in self.subviews) {
        if (subView.tag == kBackgroudTag) {
            subView.frame = self.bounds;
        }
        
        if (subView.tag == kEmojiTag) {
            subView.frame = CGRectMake(self.bounds.size.width * 0.25, self.bounds.size.height * 0.25, self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
        }
    }
}

- (void)setupMatrix {
    matrix_float3x3 kColorConversion601FullRangeMatrix = (matrix_float3x3){
        (simd_float3){1.0,    1.0,    1.0},
        (simd_float3){0.0,    -0.343, 1.765},
        (simd_float3){1.4,    -0.711, 0.0},
    };

    vector_float3 kColorConversion601FullRangeOffset = (vector_float3){ -(16.0/255.0), -0.5, -0.5};

    LYConvertMatrix matrix;
    matrix.matrix = kColorConversion601FullRangeMatrix;
    matrix.offset = kColorConversion601FullRangeOffset;

    self.convertMatrix = [self.mtkView.device newBufferWithBytes:&matrix
                                                          length:sizeof(LYConvertMatrix)
                                                         options:MTLResourceStorageModeShared];
}

-(void)setupPipeline {
    id<MTLLibrary> defaultLibrary = [self.mtkView.device newDefaultLibrary];
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"samplingShader"];
    
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = self.mtkView.colorPixelFormat;
    self.pipelineState = [self.mtkView.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                                             error:NULL];
    self.commandQueue = [self.mtkView.device newCommandQueue];
}

- (void)setupVertex:(ZoomVideoSDKVideoRawDataRotation)rotate rawSize:(CGSize)rawSize display:(DisplayMode)mode mirror:(BOOL)mirror {
    
    CGSize cropSize = [self cropSizeWithRawSize:rawSize andModel:mode rotate:rotate];
    
    switch (rotate) {
        case ZoomVideoSDKVideoRawDataRotationNone: {
            if (mirror) {
                LYVertex quadVertices[] =
                {
                    { { -1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 1.f } },
                    { {  1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 1.f } },
                    { { -1.0 * cropSize.width,  1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 0.f } },
                    
                    { {  1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 1.f } },
                    { {  1.0 * cropSize.width,  1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 0.f } },
                    { { -1.0 * cropSize.width,  1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 0.f } },
                };
                self.vertices = [self.mtkView.device newBufferWithBytes:quadVertices
                                                                 length:sizeof(quadVertices)
                                                                options:MTLResourceStorageModeShared];
                self.numVertices = sizeof(quadVertices) / sizeof(LYVertex);
            } else {
                LYVertex quadVertices[] =
                {
                    { {  1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 1.f } },
                    { { -1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 1.f } },
                    { {  1.0 * cropSize.width,  1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 0.f } },
                    
                    { { -1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 1.f } },
                    { { -1.0 * cropSize.width,  1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 0.f } },
                    { {  1.0 * cropSize.width,  1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 0.f } },
                };
                self.vertices = [self.mtkView.device newBufferWithBytes:quadVertices
                                                                 length:sizeof(quadVertices)
                                                                options:MTLResourceStorageModeShared];
                self.numVertices = sizeof(quadVertices) / sizeof(LYVertex);
            }
        }
            break;
        case ZoomVideoSDKVideoRawDataRotation90: {
            if (mirror) {
                LYVertex quadVertices[] =
                {
                    { {  1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 1.f } },
                    { { -1.0 * cropSize.width,  1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 0.f } },
                    { {  1.0 * cropSize.width,  1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 1.f } },
                    
                    { { -1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 0.f } },
                    { { -1.0 * cropSize.width,  1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 0.f } },
                    { {  1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 1.f } },
                };
                self.vertices = [self.mtkView.device newBufferWithBytes:quadVertices
                                                                 length:sizeof(quadVertices)
                                                                options:MTLResourceStorageModeShared];
                self.numVertices = sizeof(quadVertices) / sizeof(LYVertex);
            } else {
                LYVertex quadVertices[] =
                {
                    { { -1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 1.f } },
                    { {  1.0 * cropSize.width,  1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 0.f } },
                    { { -1.0 * cropSize.width,  1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 1.f } },
                    
                    { {  1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 0.f } },
                    { {  1.0 * cropSize.width,  1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 0.f } },
                    { { -1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 1.f } },
                };
                self.vertices = [self.mtkView.device newBufferWithBytes:quadVertices
                                                                 length:sizeof(quadVertices)
                                                                options:MTLResourceStorageModeShared];
                self.numVertices = sizeof(quadVertices) / sizeof(LYVertex);
            }
        }
            break;
        case ZoomVideoSDKVideoRawDataRotation180: {
            if (mirror) {
                LYVertex quadVertices[] =
                {
                    { { -1.0 * cropSize.width, 1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 1.f } },
                    { { 1.0 * cropSize.width, 1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 1.f } },
                    { { -1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 0.f } },
                    
                    { { 1.0 * cropSize.width, 1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 1.f } },
                    { { 1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 0.f } },
                    { { -1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 0.f } },
                };
                self.vertices = [self.mtkView.device newBufferWithBytes:quadVertices
                                                                 length:sizeof(quadVertices)
                                                                options:MTLResourceStorageModeShared];
                self.numVertices = sizeof(quadVertices) / sizeof(LYVertex);
            } else {
                LYVertex quadVertices[] =
                {
                    { { 1.0 * cropSize.width, 1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 1.f } },
                    { { -1.0 * cropSize.width, 1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 1.f } },
                    { { 1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 0.f } },
                    
                    { { -1.0 * cropSize.width, 1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 1.f } },
                    { { -1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 0.f } },
                    { { 1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 0.f } },
                };
                self.vertices = [self.mtkView.device newBufferWithBytes:quadVertices
                                                                 length:sizeof(quadVertices)
                                                                options:MTLResourceStorageModeShared];
                self.numVertices = sizeof(quadVertices) / sizeof(LYVertex);
            }
        }
            break;
        case ZoomVideoSDKVideoRawDataRotation270: {
            if (mirror) {
                LYVertex quadVertices[] =
                {
                    { { -1.0 * cropSize.width, 1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 1.f } },
                    { { 1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 0.f } },
                    { { -1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 1.f } },
                    
                    { { -1.0 * cropSize.width, 1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 1.f } },
                    { { 1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 0.f } },
                    { { 1.0 * cropSize.width, 1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 0.f } },
                };
                self.vertices = [self.mtkView.device newBufferWithBytes:quadVertices
                                                                 length:sizeof(quadVertices)
                                                                options:MTLResourceStorageModeShared];
                self.numVertices = sizeof(quadVertices) / sizeof(LYVertex);
            } else {
                  LYVertex quadVertices[] =
                  {
                      { { 1.0 * cropSize.width, 1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 1.f } },
                      { { -1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 0.f } },
                      { { 1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 1.f } },
                      
                      { { 1.0 * cropSize.width, 1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 1.f } },
                      { { -1.0 * cropSize.width, -1.0 * cropSize.height, 0.0, 1.0 },  { 0.f, 0.f } },
                      { { -1.0 * cropSize.width, 1.0 * cropSize.height, 0.0, 1.0 },  { 1.f, 0.f } },
                  };
                  self.vertices = [self.mtkView.device newBufferWithBytes:quadVertices
                                                                   length:sizeof(quadVertices)
                                                                  options:MTLResourceStorageModeShared];
                  self.numVertices = sizeof(quadVertices) / sizeof(LYVertex);
            }
        }
            break;
        default:
            break;
    }
}

- (CGSize)cropSizeWithRawSize:(CGSize)rawSize andModel:(DisplayMode)mode rotate:(ZoomVideoSDKVideoRawDataRotation)rotate {
    
    CGSize displaySize = CGSizeMake(self.viewportSize.x, self.viewportSize.y);
    CGSize cropSize = CGSizeMake(0.0, 0.0);
    CGSize sourceSize = CGSizeMake(rawSize.width, rawSize.height);
    if (rotate == ZoomVideoSDKVideoRawDataRotation90 || rotate == ZoomVideoSDKVideoRawDataRotation270) {
        sourceSize = CGSizeMake(rawSize.height, rawSize.width);
    }
    CGSize cropScale = CGSizeMake(sourceSize.width/displaySize.width, sourceSize.height/displaySize.height);
    
    if (mode == DisplayMode_PanAndScan) {
        if (cropScale.width > cropScale.height) {
            cropSize.height = 1.0;
            cropSize.width = cropScale.width/cropScale.height;
        }
        else {
            cropSize.width = 1.0;
            cropSize.height = cropScale.height/cropScale.width;
        }
    } else if (mode == DisplayMode_LetterBox) {
        if (cropScale.width > cropScale.height) {
            cropSize.width = 1.0;
            cropSize.height = cropScale.height/cropScale.width;
        }
        else {
            cropSize.height = 1.0;
            cropSize.width = cropScale.width/cropScale.height;
        }
    }
    
    return cropSize;
}

- (void)setupTextureWithEncoder:(id<MTLRenderCommandEncoder>)encoder buffer:(CVPixelBufferRef)pixelBuffer {
    
    {
        size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
        size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
        MTLPixelFormat pixelFormat = MTLPixelFormatR8Unorm;
        
        CVMetalTextureRef texture = NULL;
        CVReturn status = CVMetalTextureCacheCreateTextureFromImage(NULL, self.textureCache, pixelBuffer, NULL, pixelFormat, width, height, 0, &texture);
        if(status == kCVReturnSuccess)
        {
            self.textureY = CVMetalTextureGetTexture(texture);
        }
        CFRelease(texture);
    }
    
    {
        size_t width2 = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
        size_t height2 = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
        MTLPixelFormat pixelFormat = MTLPixelFormatRG8Unorm;
        
        CVMetalTextureRef texture2 = NULL;
        CVReturn status = CVMetalTextureCacheCreateTextureFromImage(NULL, self.textureCache, pixelBuffer, NULL, pixelFormat, width2, height2, 1, &texture2);
        if(status == kCVReturnSuccess)
        {
            self.textureUV = CVMetalTextureGetTexture(texture2);
        }
        CFRelease(texture2);
    }
    
    if(self.textureY != nil && self.textureUV != nil)
    {
        [encoder setFragmentTexture:self.textureY
                            atIndex:LYFragmentTextureIndexTextureY];
        [encoder setFragmentTexture:self.textureUV
                            atIndex:LYFragmentTextureIndexTextureUV];
    }
}

#pragma mark - delegate
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size  API_AVAILABLE(ios(9.0)){
    self.viewportSize = (vector_uint2){size.width, size.height};
}


- (void)drawInMTKView:(MTKView *)view  API_AVAILABLE(ios(9.0)){
    if (!self.pixelBuffer) {
        return;
    }

    [self display:self.pixelBuffer];
}

- (void)display:(CVPixelBufferRef)pixelBuffer
{
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    
    dispatch_semaphore_wait(_inflight_semaphore, DISPATCH_TIME_FOREVER);
    
    __block dispatch_semaphore_t block_semaphore = _inflight_semaphore;
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> handler) {
        // GPU work completed.
        dispatch_semaphore_signal(block_semaphore);
    }];
    
    MTLRenderPassDescriptor *renderPassDescriptor = self.mtkView.currentRenderPassDescriptor;
    if(renderPassDescriptor)
    {
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0f);
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, self.viewportSize.x, self.viewportSize.y, -1.0, 1.0 }];
        [renderEncoder setRenderPipelineState:self.pipelineState];
        
        [renderEncoder setVertexBuffer:self.vertices
                                offset:0
                               atIndex:LYVertexInputIndexVertices];
        
        [self setupTextureWithEncoder:renderEncoder buffer:pixelBuffer];
        [renderEncoder setFragmentBuffer:self.convertMatrix
                                  offset:0
                                 atIndex:LYFragmentInputIndexMatrix];
        
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:self.numVertices];
        
        [renderEncoder endEncoding];
        
        [commandBuffer presentDrawable:self.mtkView.currentDrawable];
        renderEncoder = NULL;
    }
    
    [commandBuffer commit];

    self.textureY = NULL;
    self.textureUV = NULL;
    self.pixelBuffer = NULL;
}

- (void)displayMetal:(CVPixelBufferRef)pixelBuffer rotation:(ZoomVideoSDKVideoRawDataRotation)rotation display:(DisplayMode)mode mirror:(BOOL)mirror
{
    self.pixelBuffer = pixelBuffer;

    size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
    size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
    [self setupVertex:rotation rawSize:CGSizeMake(width, height) display:mode mirror:mirror];
    [self.mtkView draw];
}

- (void)addAvatar {
    UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
    bgView.backgroundColor = RGBCOLOR(0x23, 0x23, 0x23);
    bgView.tag = kBackgroudTag;
    [self addSubview:bgView];
    [self insertSubview:bgView aboveSubview:self.mtkView];
    
    NSString *imageName = [NSString stringWithFormat:@"default_avatar"];
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *view = [[UIImageView alloc] initWithImage:image];
    view.frame = CGRectMake(self.bounds.size.width * 0.25, self.bounds.size.height * 0.25, self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    view.contentMode = UIViewContentModeScaleAspectFit;
    view.tag = kEmojiTag;
    [self addSubview:view];
}

- (void)removeAvatar {
    NSMutableArray *needRemove = [NSMutableArray new];
    for (UIView *view in [self subviews]) {
        if (view.tag == kEmojiTag) {
            [needRemove addObject:view];
        }
        if (view.tag == kBackgroudTag) {
            [needRemove addObject:view];
        }
    }
    [needRemove makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end
